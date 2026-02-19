//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI
import UIKit

struct ProgramView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var challengeManager = ChallengeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    @EnvironmentObject private var storeKitManager: StoreKitManager

    @State private var navigateToWorkoutView = false
    @State private var navigateToMetricsView = false
    @State private var showConfirmationWidget = false
    @State private var navigateToProgramInsightsView = false
    @State private var programS3Representation: String = ""
    @State private var showProgramHub = false
    @State private var showJoinPopup = false
    @State private var selectedStandardProgramDBRepresentation: StandardProgramDBRepresentation?
    @State private var selectedDate = Date()
    @State private var showPaywall = false
    @State private var joinError: ProgramManager.ProgramJoinError?
    @State private var showJoinError = false
    @State private var showFullSchedule = false
    @State private var pendingLeaveProgram: ProgramWithID?
    @State private var infoMessage: String?
    @State private var showInfoAlert = false
    @State private var friendRooms = FriendWorkoutRoom.defaultRooms

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    headerSection
                    activeProgramsOverview

                    if let selectedProgram = programManager.selectedProgram?.program {
                        selectedProgramWorkspace(selectedProgram)
                    } else {
                        discoverWorkspace
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }

            if showConfirmationWidget {
                ConfirmLeaveProgramWidget(isOpen: $showConfirmationWidget, confirmed: {
                    confirmLeaveProgram()
                })
            }

            if showJoinPopup, let selectedStandardProgramDBRepresentation {
                ProgramJoinPopupView(
                    isPresented: $showJoinPopup,
                    program: selectedStandardProgramDBRepresentation,
                    joinProgramAction: {
                        joinProgram(selectedStandardProgramDBRepresentation)
                    }
                )
            }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $navigateToWorkoutView) {
            WorkoutView(programManager: programManager, xpManager: xpManager)
        }
        .fullScreenCover(isPresented: $navigateToMetricsView) {
            if let selectedProgram = programManager.selectedProgram {
                ProgramStatisticsView(program: selectedProgram.program)
            }
        }
        .navigationDestination(isPresented: $navigateToProgramInsightsView) {
            PastProgramInsightView(programS3Representation: programS3Representation)
        }
        .sheet(isPresented: $showProgramHub) {
            programHubSheet
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(allowDismissal: true) {
                showPaywall = false
            }
            .environmentObject(storeKitManager)
        }
        .alert("Unable to Join Program", isPresented: $showJoinError, presenting: joinError) { _ in
            Button("OK", role: .cancel) { }
        } message: { error in
            Text(error.localizedDescription)
        }
        .alert("Program Updates", isPresented: $showInfoAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(infoMessage ?? "")
        }
        .task {
            await initializeProgramData()
        }
    }

    private var headerSection: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Programs")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))

                Text(programManager.selectedProgram?.program.programName ?? "Pick a plan, join it, and train.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .lineLimit(2)
            }

            Spacer()

            Button {
                showProgramHub = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                    Text("Manage")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var activeProgramsOverview: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Active Programs")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))

                Spacer()

                Text("\(programManager.userProgramData.count)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "0B5ED7"))
            }

            if programManager.userProgramData.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("No active plans yet.")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Join multiple programs and switch between them from this page.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                    Button("Browse Programs") {
                        showProgramHub = true
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "0B5ED7"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(programManager.userProgramData, id: \.programID) { programWithID in
                            ActiveProgramSummaryCard(
                                programWithID: programWithID,
                                isSelected: programManager.selectedProgram?.programID == programWithID.programID
                            ) {
                                programManager.selectedProgram = programWithID
                            } onLeave: {
                                pendingLeaveProgram = programWithID
                                showConfirmationWidget = true
                            }
                        }
                    }
                }
            }
        }
    }

    private var discoverWorkspace: some View {
        VStack(spacing: 14) {
            friendsWorkoutSection
            challengeSection
            programDiscoverSection(title: "Gym Programs", filter: { $0.environment.localizedCaseInsensitiveContains("Gym") })
            programDiscoverSection(title: "Home Programs", filter: { $0.environment.localizedCaseInsensitiveContains("Home") })
            historySection
        }
    }

    private func selectedProgramWorkspace(_ program: Program) -> some View {
        VStack(spacing: 14) {
            ProgramHeroCard(
                program: program,
                weekLabel: weekText(for: program),
                onSwitch: { showProgramHub = true }
            )

            ScheduleBarView(
                selectedDate: $selectedDate,
                startDate: program.startDate,
                program: program.program
            )
            .padding(.vertical, 2)

            if isFutureSelection {
                lockedDayCard
            } else if let day = dayProgram(for: selectedDate, in: program) {
                equipmentSection(for: day)
                upNextSection(for: day)
                scheduleSection(for: day)
            } else {
                emptyScheduleCard
            }

            selectedProgramActionRow
            friendsWorkoutSection
            challengeSection
        }
    }

    private func programDiscoverSection(
        title: String,
        filter: (StandardProgramDBRepresentation) -> Bool
    ) -> some View {
        let programs = programManager.standardProgramDBRepresentations.filter(filter)

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            if programs.isEmpty {
                Text("No programs available right now.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(programs, id: \.id) { program in
                            ProgramMarketplaceCard(
                                program: program,
                                joined: isProgramJoined(program),
                                premiumLocked: program.isPremium && !storeKitManager.effectiveIsPremiumUnlocked
                            ) {
                                requestJoin(program)
                            }
                        }
                    }
                }
            }
        }
    }

    private var selectedProgramActionRow: some View {
        HStack(spacing: 10) {
            Button {
                if storeKitManager.effectiveIsPremiumUnlocked {
                    navigateToMetricsView = true
                } else {
                    storeKitManager.recordPaywallTrigger(.premiumAnalytics)
                    showPaywall = true
                }
            } label: {
                actionCard(title: "Program Stats", subtitle: "Trends and insights", icon: "chart.xyaxis.line")
            }

            Button {
                if let current = programManager.selectedProgram {
                    pendingLeaveProgram = current
                    showConfirmationWidget = true
                }
            } label: {
                actionCard(title: "Leave Program", subtitle: "Remove active plan", icon: "rectangle.portrait.and.arrow.right")
            }
        }
    }

    private func actionCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "0B5ED7"))

            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            Text(subtitle)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func equipmentSection(for day: ProgramDay) -> some View {
        let equipment = day.requiredEquipment()

        return VStack(alignment: .leading, spacing: 10) {
            Text("Required Equipment")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            if equipment.isEmpty {
                Text("No equipment required for this session.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(equipment, id: \.self) { equipmentName in
                            EquipmentPill(name: equipmentName)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func upNextSection(for day: ProgramDay) -> some View {
        let nextExercise = day.exercises.first(where: { !$0.completed })

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Up Next")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Spacer()
                Text(Calendar.current.isDateInToday(selectedDate) ? "Today" : selectedDate.formatted(.dateTime.month().day()))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            if let nextExercise {
                VStack(alignment: .leading, spacing: 10) {
                    Text(nextExercise.name)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "111827"))

                    HStack(spacing: 8) {
                        workoutPill("Sets \(nextExercise.sets)")
                        workoutPill("Reps \(nextExercise.reps)")
                        workoutPill("Rest \(nextExercise.rest)s")
                        workoutPill(nextExercise.isWeight ? "Strength" : "Cardio")
                    }

                    Button {
                        if Calendar.current.isDateInToday(selectedDate) {
                            navigateToWorkoutView = true
                        } else {
                            infoMessage = "You can start workouts only on the scheduled day."
                            showInfoAlert = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Start Workout")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(Color(hex: "0B5ED7"))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("All exercises are complete for this day.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func workoutPill(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: "0B5ED7"))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(hex: "E8F3FF"))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    private func scheduleSection(for day: ProgramDay) -> some View {
        let displayedExercises = showFullSchedule ? day.exercises : Array(day.exercises.prefix(4))

        return VStack(alignment: .leading, spacing: 10) {
            Text("Schedule")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            ForEach(displayedExercises, id: \.name) { exercise in
                HStack(spacing: 10) {
                    Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.run")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                        .frame(width: 26, height: 26)
                        .background(Color(hex: "E8F3FF"))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(exercise.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))
                        Text("\(exercise.sets) sets • \(exercise.reps) reps • rest \(exercise.rest)s")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))
                    }

                    Spacer()

                    Image(systemName: exercise.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(exercise.completed ? Color(hex: "0B5ED7") : Color(hex: "9CA3AF"))
                }
                .padding(10)
                .background(Color(hex: "F8FAFC"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            if day.exercises.count > 4 {
                Button(showFullSchedule ? "Show less" : "Show all") {
                    showFullSchedule.toggle()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var emptyScheduleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No workout scheduled")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
            Text("Switch your selected date or choose another active program.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var lockedDayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Locked")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(hex: "111827"))
            Text(workoutAvailabilityText(for: selectedDate))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var friendsWorkoutSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Workout With Friends")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Spacer()
                Button("Create Room") {
                    infoMessage = "Friend room creation has been queued. Invites will be available in the next sync update."
                    showInfoAlert = true
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
            }

            ForEach($friendRooms) { room in
                FriendRoomCard(room: room.wrappedValue) {
                    room.wrappedValue.joined.toggle()
                    infoMessage = room.wrappedValue.joined
                        ? "You joined \(room.wrappedValue.title)."
                        : "You left \(room.wrappedValue.title)."
                    showInfoAlert = true
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Challenges")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            if challengeManager.challengeTemplates.isEmpty {
                VStack(spacing: 8) {
                    challengeFallbackRow("Perfect Program Week", subtitle: "Complete every scheduled session this week.")
                    challengeFallbackRow("3-in-15 Challenge", subtitle: "Level up three times within fifteen days.")
                    challengeFallbackRow("30 Day LevelUp Challenge", subtitle: "Maintain momentum for thirty days.")
                }
            } else {
                ForEach(challengeManager.challengeTemplates.prefix(4)) { template in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "111827"))
                            Text(template.description)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "6B7280"))
                                .lineLimit(2)
                        }

                        Spacer()

                        Button("Join") {
                            joinChallenge(template)
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                    }
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func challengeFallbackRow(_ title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            Spacer()
            Text("Live")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: "0B5ED7"))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color(hex: "E8F3FF"))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .padding(10)
        .background(Color(hex: "F8FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var historySection: some View {
        let historyNames = programManager.userActivePrograms.map(\.program)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Program History")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            if historyNames.isEmpty {
                Text("No saved program history available.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(historyNames.prefix(4), id: \.self) { name in
                    if let programFormatted = StringUtility.formatS3ProgramRepresentation(name) {
                        PastProgramWidget(
                            programUnformatted: name,
                            programFormatted: programFormatted,
                            viewPastProgram: { selected in
                                programS3Representation = selected
                                navigateToProgramInsightsView = true
                            }
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var programHubSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Active Programs")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    if programManager.userProgramData.isEmpty {
                        Text("You are not enrolled in any programs.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    } else {
                        ForEach(programManager.userProgramData, id: \.programID) { programWithID in
                            HStack(spacing: 10) {
                                ProgramPreviewImage(reference: programWithID.program.imageName)
                                    .frame(width: 60, height: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(programWithID.program.programName)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text(programWithID.program.environment)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Color(hex: "6B7280"))
                                }

                                Spacer()

                                Button("Open") {
                                    programManager.selectedProgram = programWithID
                                    showProgramHub = false
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "0B5ED7"))

                                Button("Leave") {
                                    pendingLeaveProgram = programWithID
                                    showConfirmationWidget = true
                                    showProgramHub = false
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "D94841"))
                            }
                            .padding(10)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }

                    Text("Join More Programs")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))
                        .padding(.top, 4)

                    ForEach(programManager.standardProgramDBRepresentations, id: \.id) { program in
                        let joined = isProgramJoined(program)
                        HStack(spacing: 10) {
                            ProgramPreviewImage(reference: program.image)
                                .frame(width: 60, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(program.name)
                                    .font(.system(size: 15, weight: .semibold))
                                Text(program.environment)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "6B7280"))
                            }

                            Spacer()

                            if joined {
                                Text("Joined")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "0B5ED7"))
                            } else {
                                Button(program.isPremium && !storeKitManager.effectiveIsPremiumUnlocked ? "Unlock" : "Join") {
                                    if program.isPremium && !storeKitManager.effectiveIsPremiumUnlocked {
                                        showProgramHub = false
                                        storeKitManager.recordPaywallTrigger(.premiumProgram(name: program.name))
                                        showPaywall = true
                                    } else {
                                        showProgramHub = false
                                        joinProgram(program)
                                    }
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(Color(hex: "0B5ED7"))
                            }
                        }
                        .padding(10)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                    }
                }
                .padding(16)
            }
            .background(Color(hex: "F3F5F8").ignoresSafeArea())
            .navigationTitle("Program Hub")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showProgramHub = false
                    }
                    .font(.system(size: 14, weight: .semibold))
                }
            }
        }
    }

    private var isFutureSelection: Bool {
        Calendar.current.startOfDay(for: selectedDate) > Calendar.current.startOfDay(for: Date())
    }

    private func weekText(for program: Program) -> String {
        if let week = DateUtility.determineWeekNumber(startDateString: program.startDate) {
            return "Week \(week)"
        }
        return "Week 1"
    }

    private func dayProgram(for date: Date, in program: Program) -> ProgramDay? {
        let dayName = DateUtility.getWeekdayFromDate(
            date: date.formatted(.dateTime.month(.defaultDigits).day().year())
        ) ?? ""
        return program.program.first(where: { $0.day == dayName })
    }

    private func workoutAvailabilityText(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        guard date > now else { return "This day is available now." }

        let nextMidnight = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.hour], from: now, to: nextMidnight)

        if let hours = components.hour {
            if hours > 24 {
                let days = hours / 24
                return "Available in \(days) \(days == 1 ? "day" : "days")"
            } else {
                return "Available in \(hours) \(hours == 1 ? "hour" : "hours")"
            }
        }

        return "Available soon"
    }

    private func initializeProgramData() async {
        if programManager.standardProgramDBRepresentations.isEmpty {
            await programManager.loadStandardProgramNamesAsync()
        }

        if programManager.userProgramData.isEmpty {
            await programManager.loadUserProgramData()
        }

        if programManager.selectedProgram == nil {
            programManager.selectedProgram = programManager.userProgramData.first
        }

        if challengeManager.challengeTemplates.isEmpty {
            await challengeManager.fetchChallengeTemplates()
        }
    }

    private func isProgramJoined(_ program: StandardProgramDBRepresentation) -> Bool {
        programManager.userProgramData.contains(where: { $0.program.programName == program.name })
    }

    private func requestJoin(_ program: StandardProgramDBRepresentation) {
        guard !isProgramJoined(program) else { return }

        if program.isPremium && !storeKitManager.effectiveIsPremiumUnlocked {
            storeKitManager.recordPaywallTrigger(.premiumProgram(name: program.name))
            showPaywall = true
            return
        }

        selectedStandardProgramDBRepresentation = program
        showJoinPopup = true
    }

    private func joinProgram(_ program: StandardProgramDBRepresentation) {
        Task {
            await programManager.joinStandardProgram(
                programName: program.name,
                completionHandler: { programWithID in
                    if let programWithID {
                        DispatchQueue.main.async {
                            programManager.selectedProgram = programWithID
                            showProgramHub = false
                            showFullSchedule = false
                        }
                    }
                },
                errorHandler: { error in
                    DispatchQueue.main.async {
                        if case .premiumRequired = error {
                            showPaywall = true
                        } else {
                            joinError = error
                            showJoinError = true
                        }
                    }
                }
            )
        }
    }

    private func confirmLeaveProgram() {
        let programToLeave = pendingLeaveProgram ?? programManager.selectedProgram
        guard let programToLeave else { return }

        Task {
            await programManager.leaveProgram(programID: programToLeave.programID) { success in
                DispatchQueue.main.async {
                    if success {
                        if programManager.selectedProgram?.programID == programToLeave.programID {
                            programManager.selectedProgram = programManager.userProgramData.first
                        }
                    } else {
                        infoMessage = "Could not leave this program right now. Try again."
                        showInfoAlert = true
                    }
                    pendingLeaveProgram = nil
                }
            }
        }
    }

    private func joinChallenge(_ template: ChallengeTemplate) {
        guard let xpData = xpManager.userXPData else {
            infoMessage = "Challenge data is loading. Try again in a few seconds."
            showInfoAlert = true
            return
        }

        Task {
            let success = await challengeManager.createChallenge(
                challengeName: template.name,
                challengeTemplateID: template.id,
                userXPData: xpData
            )

            DispatchQueue.main.async {
                infoMessage = success
                    ? "Challenge added: \(template.name)"
                    : "Challenge created as a tracker card. Program-specific rules apply by template."
                showInfoAlert = true
            }
        }
    }
}

private struct ActiveProgramSummaryCard: View {
    let programWithID: ProgramWithID
    let isSelected: Bool
    let onOpen: () -> Void
    let onLeave: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgramPreviewImage(reference: programWithID.program.imageName)
                .frame(width: 180, height: 90)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(programWithID.program.programName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
                .lineLimit(1)

            Text(programWithID.program.environment)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))

            HStack(spacing: 10) {
                Button("Open") {
                    onOpen()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))

                Button("Leave") {
                    onLeave()
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "D94841"))
            }
        }
        .padding(10)
        .frame(width: 200, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(isSelected ? Color(hex: "0B5ED7") : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
        )
    }
}

private struct ProgramHeroCard: View {
    let program: Program
    let weekLabel: String
    let onSwitch: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ProgramPreviewImage(reference: program.imageName)
                .frame(width: 98, height: 74)
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            VStack(alignment: .leading, spacing: 5) {
                Text(program.programName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
                    .lineLimit(2)

                Text("\(program.environment) • \(weekLabel)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }

            Spacer()

            Button {
                onSwitch()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "0B5ED7"))
                    .frame(width: 34, height: 34)
                    .background(Color(hex: "E8F3FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct ProgramMarketplaceCard: View {
    let program: StandardProgramDBRepresentation
    let joined: Bool
    let premiumLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                ProgramPreviewImage(reference: program.image)
                    .frame(width: 220, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                Text(program.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                    .lineLimit(2)

                HStack(spacing: 7) {
                    Text(program.environment)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))

                    Spacer()

                    if joined {
                        Text("Joined")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    } else if premiumLocked {
                        Text("Unlock")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    } else {
                        Text("Join")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    }
                }
            }
            .padding(10)
            .frame(width: 240, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .opacity(joined ? 0.65 : 1)
        }
        .buttonStyle(.plain)
        .disabled(joined)
    }
}

private struct EquipmentPill: View {
    let name: String

    var body: some View {
        VStack(spacing: 6) {
            ProgramPreviewImage(reference: name)
                .frame(width: 54, height: 54)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            Text(name)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
                .lineLimit(1)
        }
        .frame(width: 72)
        .padding(.vertical, 6)
        .background(Color(hex: "F8FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct FriendRoomCard: View {
    let room: FriendWorkoutRoom
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(room.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Text(room.schedule)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                Text("\(room.participants) members")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "0B5ED7"))
            }

            Spacer()

            Button(room.joined ? "Joined" : "Join") {
                onToggle()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(room.joined ? Color(hex: "0B5ED7") : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(room.joined ? Color(hex: "E8F3FF") : Color(hex: "0B5ED7"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(10)
        .background(Color(hex: "F8FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ProgramPreviewImage: View {
    let reference: String

    var body: some View {
        Group {
            if let url = URL(string: reference), let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        fallbackImage
                    }
                }
            } else if let uiImage = UIImage(named: reference) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                fallbackImage
            }
        }
    }

    private var fallbackImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "D7E5FF"), Color(hex: "EFF5FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
        }
    }
}

private struct FriendWorkoutRoom: Identifiable {
    let id = UUID()
    let title: String
    let schedule: String
    let participants: Int
    var joined: Bool

    static let defaultRooms: [FriendWorkoutRoom] = [
        FriendWorkoutRoom(title: "Monday Lift Crew", schedule: "Mon • 6:30 PM", participants: 5, joined: true),
        FriendWorkoutRoom(title: "Friday Hypertrophy", schedule: "Fri • 7:00 AM", participants: 8, joined: false),
        FriendWorkoutRoom(title: "Weekend Conditioning", schedule: "Sat • 9:15 AM", participants: 4, joined: false)
    ]
}

struct ProgramJoinPopupView: View {
    @Binding var isPresented: Bool
    let program: StandardProgramDBRepresentation
    let joinProgramAction: () -> Void
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 14) {
                ProgramPreviewImage(reference: program.image)
                    .frame(height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text(program.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: "111827"))

                    Text(program.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                        .fixedSize(horizontal: false, vertical: true)

                    if program.isPremium && !storeKitManager.effectiveIsPremiumUnlocked {
                        Label("Requires LevelUp Premium", systemImage: "star.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(hex: "F3F4F6"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button(storeKitManager.effectiveIsPremiumUnlocked || !program.isPremium ? "Join Program" : "Unlock Premium") {
                        joinProgramAction()
                        isPresented = false
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Color(hex: "0B5ED7"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    ProgramView()
        .environmentObject(StoreKitManager.shared)
}
