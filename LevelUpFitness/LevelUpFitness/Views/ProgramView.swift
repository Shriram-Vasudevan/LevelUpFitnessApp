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
    @ObservedObject var friendWorkoutManager = FriendWorkoutManager.shared
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
    @State private var showFriendRoomComposer = false
    @State private var showGlobalRoomDirectory = false

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark
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
        .sheet(isPresented: $showFriendRoomComposer) {
            CreateFriendRoomSheet(context: .program) { title, date, isPublic in
                Task {
                    let success = await friendWorkoutManager.createRoom(
                        context: .program,
                        title: title,
                        scheduleDate: date,
                        isPublic: isPublic
                    )
                    infoMessage = success
                        ? "Friend workout room created."
                        : (friendWorkoutManager.syncErrorMessage ?? "Could not create room right now.")
                    showInfoAlert = true
                }
            }
        }
        .sheet(isPresented: $showGlobalRoomDirectory) {
            GlobalFriendRoomDirectorySheet(initialContext: .program) { message in
                infoMessage = message
                showInfoAlert = true
            }
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
                    .font(AppTheme.Typography.telemetry(size: 31, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text(programManager.selectedProgram?.program.programName ?? "Pick a plan, join it, and train.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
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
                .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
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
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Spacer()

                Text("\(programManager.userProgramData.count)")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)

                Button("Manage") {
                    showProgramHub = true
                }
                .font(AppTheme.Typography.telemetry(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
            }

            if programManager.userProgramData.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("No active plans yet.")
                        .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                    Text("Join multiple programs and switch between them from this page.")
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    Button("Browse Programs") {
                        showProgramHub = true
                    }
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
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
                                showFullSchedule = false
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
            workspaceHeader(program)

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
                selectedDaySnapshot(for: day)
                upNextSection(for: day)
                scheduleSection(for: day)
                equipmentSection(for: day)
            } else {
                emptyScheduleCard
            }

            selectedProgramActionRow
            friendsWorkoutSection
            challengeSection
        }
    }

    private func workspaceHeader(_ program: Program) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Program Workspace")
                .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text("Selected: \(program.programName)")
                .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func programDiscoverSection(
        title: String,
        filter: (StandardProgramDBRepresentation) -> Bool
    ) -> some View {
        let programs = programManager.standardProgramDBRepresentations.filter(filter)

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            if programs.isEmpty {
                Text("No programs available right now.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
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
                                premiumLocked: isProgramLocked(program)
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
                showProgramHub = true
            } label: {
                actionCard(title: "Manage Programs", subtitle: "Switch or leave plans", icon: "slider.horizontal.3")
            }
        }
    }

    private func actionCard(title: String, subtitle: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(AppTheme.Typography.telemetry(size: 17, weight: .bold))
                .foregroundColor(AppTheme.Colors.bluePrimary)

            Text(title)
                .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            Text(subtitle)
                .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private func equipmentSection(for day: ProgramDay) -> some View {
        let equipment = day.requiredEquipment()

        return VStack(alignment: .leading, spacing: 10) {
            Text("Required Equipment")
                .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            if equipment.isEmpty {
                Text("No equipment required for this session.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
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
        .engineeredPanel(isElevated: false)
    }

    private func selectedDaySnapshot(for day: ProgramDay) -> some View {
        let totalCount = day.exercises.count
        let completedCount = day.exercises.filter { $0.completed }.count
        let pendingCount = max(totalCount - completedCount, 0)
        let completionText = "\(completedCount)/\(totalCount) complete"

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(Calendar.current.isDateInToday(selectedDate) ? "Today's Plan" : selectedDate.formatted(.dateTime.weekday(.wide).month().day()))
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Text(day.day)
                    .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "E8F3FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }

            HStack(spacing: 8) {
                workoutPill("\(totalCount) exercises")
                workoutPill("\(pendingCount) pending")
                workoutPill(completionText)
            }
        }
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private func upNextSection(for day: ProgramDay) -> some View {
        let nextExercise = day.exercises.first(where: { !$0.completed })

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Up Next")
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Text(Calendar.current.isDateInToday(selectedDate) ? "Today" : selectedDate.formatted(.dateTime.month().day()))
                    .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            if let nextExercise {
                VStack(alignment: .leading, spacing: 10) {
                    Text(nextExercise.name)
                        .font(AppTheme.Typography.telemetry(size: 17, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

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
                                .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .background(AppTheme.Colors.bluePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("All exercises are complete for this day.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private func workoutPill(_ label: String) -> some View {
        Text(label)
            .font(AppTheme.Typography.telemetry(size: 12, weight: .semibold))
            .foregroundColor(AppTheme.Colors.bluePrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(hex: "E8F3FF"))
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
    }

    private func scheduleSection(for day: ProgramDay) -> some View {
        let displayedExercises = showFullSchedule ? day.exercises : Array(day.exercises.prefix(4))

        return VStack(alignment: .leading, spacing: 10) {
            Text("Exercise Sequence")
                .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            ForEach(Array(displayedExercises.enumerated()), id: \.offset) { _, exercise in
                HStack(spacing: 10) {
                    Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.run")
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                        .frame(width: 26, height: 26)
                        .background(Color(hex: "E8F3FF"))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(exercise.name)
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        Text("\(exercise.sets) sets • \(exercise.reps) reps • rest \(exercise.rest)s")
                            .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }

                    Spacer()

                    Image(systemName: exercise.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(exercise.completed ? AppTheme.Colors.bluePrimary : Color(hex: "9CA3AF"))
                }
                .padding(10)
                .background(Color(hex: "F8FAFC"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            if day.exercises.count > 4 {
                Button(showFullSchedule ? "Show less" : "Show all") {
                    showFullSchedule.toggle()
                }
                .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
            }
        }
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private var emptyScheduleCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No workout scheduled")
                .font(AppTheme.Typography.telemetry(size: 17, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text("Switch your selected date or choose another active program.")
                .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private var lockedDayCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Locked")
                .font(AppTheme.Typography.telemetry(size: 17, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text(workoutAvailabilityText(for: selectedDate))
                .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private var friendsWorkoutSection: some View {
        let rooms = friendWorkoutManager.rooms(for: .program)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Workout With Friends")
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Button {
                    Task {
                        await friendWorkoutManager.refresh(context: .program)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(AppTheme.Typography.telemetry(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                        .frame(width: 28, height: 28)
                        .background(Color(hex: "E8F3FF"))
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
                .buttonStyle(.plain)
                Button("Global") {
                    showGlobalRoomDirectory = true
                }
                .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
                Button("Create Room") {
                    showFriendRoomComposer = true
                }
                .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
            }

            if rooms.isEmpty {
                Text("No friend rooms yet. Create one, then share the room code or open the global directory.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(rooms) { room in
                    FriendRoomCard(room: room) {
                        Task {
                            let success = await friendWorkoutManager.toggleMembership(room: room)
                            infoMessage = success
                                ? (room.joined ? "You left \(room.title)." : "You joined \(room.title).")
                                : (friendWorkoutManager.syncErrorMessage ?? "Unable to update room membership.")
                            showInfoAlert = true
                        }
                    }
                }
            }
        }
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Challenges")
                .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            if challengeManager.challengeTemplates.isEmpty {
                VStack(spacing: 8) {
                    challengeFallbackRow("Perfect Program Week", subtitle: "Complete every scheduled session this week.")
                    challengeFallbackRow("3-in-15 Challenge", subtitle: "Level up three times within fifteen days.")
                    challengeFallbackRow("30 Day LevelUp Challenge", subtitle: "Maintain momentum for thirty days.")
                    challengeFallbackRow("Consistency Sprint", subtitle: "Hit all planned sessions for ten consecutive days.")
                    challengeFallbackRow("Volume Builder", subtitle: "Increase your total lifted volume by 8% this month.")
                    challengeFallbackRow("Recovery Discipline", subtitle: "Stay inside target rest windows for seven workouts.")
                }
            } else {
                ForEach(challengeManager.challengeTemplates.prefix(6)) { template in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Text(template.description)
                                .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .lineLimit(2)
                        }

                        Spacer()

                        Button("Join") {
                            joinChallenge(template)
                        }
                        .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                    }
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
        .padding(12)
        .engineeredPanel(isElevated: false)
    }

    private func challengeFallbackRow(_ title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(subtitle)
                    .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            Text("Live")
                .font(AppTheme.Typography.telemetry(size: 11, weight: .bold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
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
                .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            if historyNames.isEmpty {
                Text("No saved program history available.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
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
        .engineeredPanel(isElevated: false)
    }

    private var programHubSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Active Programs")
                        .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    if programManager.userProgramData.isEmpty {
                        Text("You are not enrolled in any programs.")
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
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
                                        .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                                    Text(programWithID.program.environment)
                                        .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }

                                Spacer()

                                if programManager.selectedProgram?.programID == programWithID.programID {
                                    Text("Current")
                                        .font(AppTheme.Typography.telemetry(size: 11, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.bluePrimary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 5)
                                        .background(Color(hex: "E8F3FF"))
                                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                } else {
                                    Button("Set Current") {
                                        programManager.selectedProgram = programWithID
                                    }
                                    .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.bluePrimary)
                                }

                                Menu {
                                    Button("Remove Program", role: .destructive) {
                                        pendingLeaveProgram = programWithID
                                        showConfirmationWidget = true
                                        showProgramHub = false
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .font(AppTheme.Typography.telemetry(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .frame(width: 30, height: 30)
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

                    Text("Join More Programs")
                        .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .padding(.top, 4)

                    let joinablePrograms = programManager.standardProgramDBRepresentations.filter { !isProgramJoined($0) }
                    if joinablePrograms.isEmpty {
                        Text("You've joined every available program.")
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }

                    ForEach(joinablePrograms, id: \.id) { program in
                        HStack(spacing: 10) {
                            ProgramPreviewImage(reference: program.image)
                                .frame(width: 60, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(program.name)
                                    .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                                Text(program.environment)
                                    .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }

                            Spacer()

                            Button(isProgramLocked(program) ? "Unlock" : "Join") {
                                if isProgramLocked(program) {
                                    showProgramHub = false
                                    storeKitManager.recordPaywallTrigger(.premiumProgram(name: program.name))
                                    showPaywall = true
                                } else {
                                    showProgramHub = false
                                    joinProgram(program)
                                }
                            }
                            .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
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
            .background(AppTheme.Colors.backgroundDark.ignoresSafeArea())
            .navigationTitle("Program Hub")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showProgramHub = false
                    }
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
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

        await friendWorkoutManager.refreshIfNeeded(context: .program)
    }

    private func isProgramJoined(_ program: StandardProgramDBRepresentation) -> Bool {
        let target = normalizeProgramName(program.name)
        return programManager.userProgramData.contains(where: {
            normalizeProgramName($0.program.programName) == target
        })
    }

    private func requestJoin(_ program: StandardProgramDBRepresentation) {
        guard !isProgramJoined(program) else { return }

        if isProgramLocked(program) {
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

    private func normalizeProgramName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
    }

    private func isProgramLocked(_ program: StandardProgramDBRepresentation) -> Bool {
        !storeKitManager.canAccessProgram(program)
    }
}

private struct ActiveProgramSummaryCard: View {
    let programWithID: ProgramWithID
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                ProgramPreviewImage(reference: programWithID.program.imageName)
                    .frame(width: 180, height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(programWithID.program.programName)
                    .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(1)

                HStack {
                    Text(programWithID.program.environment)
                        .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    Spacer()

                    Text(isSelected ? "Current" : "Select")
                        .font(AppTheme.Typography.telemetry(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "E8F3FF"))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }

                Text(isSelected ? "Current plan in focus" : "Tap to switch focus")
                    .font(AppTheme.Typography.telemetry(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            .padding(10)
            .frame(width: 200, height: 176, alignment: .topLeading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? AppTheme.Colors.bluePrimary : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
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
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)

                Text("\(program.environment) • \(weekLabel)")
                    .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Button {
                onSwitch()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
                    .frame(width: 34, height: 34)
                    .background(Color(hex: "E8F3FF"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .engineeredPanel(isElevated: false)
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
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .lineLimit(2)

                HStack(spacing: 7) {
                    Text(program.environment)
                        .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    Spacer()

                    if joined {
                        Text("Joined")
                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                    } else if premiumLocked {
                        Text("Unlock")
                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                    } else {
                        Text("Join")
                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                    }
                }
            }
            .padding(10)
            .frame(width: 240, height: 200, alignment: .topLeading)
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
                .font(AppTheme.Typography.telemetry(size: 11, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
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
                    .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(room.scheduleLabel)
                    .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                HStack(spacing: 6) {
                    Text("\(room.participantCount) members")
                    Text("Code \(room.roomCode)")
                    Text(room.contextLabel)
                    if room.hostedByCurrentUser {
                        Text("Host")
                            .font(AppTheme.Typography.telemetry(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "E8F3FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                    if room.isPublic {
                        Text("Public")
                            .font(AppTheme.Typography.telemetry(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "0F766E"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "DFF8F4"))
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                    }
                }
                    .font(AppTheme.Typography.telemetry(size: 12, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }

            Spacer()

            Button(room.joined ? "Leave Room" : "Join Room") {
                onToggle()
            }
            .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
            .foregroundColor(room.joined ? AppTheme.Colors.bluePrimary : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(room.joined ? Color(hex: "E8F3FF") : AppTheme.Colors.bluePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(10)
        .background(Color(hex: "F8FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct ProgramPreviewImage: View {
    let reference: String

    var body: some View {
        Group {
            if let url = resolvedURL {
                AsyncImage(url: url, transaction: Transaction(animation: .easeInOut(duration: 0.15))) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .empty:
                        loadingImage
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
        .clipped()
    }

    private var resolvedURL: URL? {
        if let url = URL(string: reference), let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
            return url
        }

        guard let encoded = reference.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedURL = URL(string: encoded),
              let scheme = encodedURL.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            return nil
        }

        return encodedURL
    }

    private var loadingImage: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "EEF3FF"), Color(hex: "F7FAFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            ProgressView()
                .tint(AppTheme.Colors.bluePrimary)
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
                .font(AppTheme.Typography.telemetry(size: 22, weight: .semibold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
        }
    }
}

struct ProgramJoinPopupView: View {
    @Binding var isPresented: Bool
    let program: StandardProgramDBRepresentation
    let joinProgramAction: () -> Void
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        ZStack {
            Color.black.opacity(0.24)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }

            VStack(spacing: 16) {
                ProgramPreviewImage(reference: program.image)
                    .frame(height: 164)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text(program.environment)
                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color(hex: "E8F3FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                        if program.requiresSubscription {
                            Label(
                                storeKitManager.canAccessProgram(program) ? "Premium" : "Subscription Required",
                                systemImage: "star.fill"
                            )
                            .font(AppTheme.Typography.telemetry(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "A16207"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color(hex: "FEF3C7"))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }

                    Text(program.name)
                        .font(AppTheme.Typography.telemetry(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(program.description)
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 10) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "F3F4F6"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button(storeKitManager.canAccessProgram(program) ? "Join Program" : "Unlock Subscription") {
                        joinProgramAction()
                        isPresented = false
                    }
                    .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.bluePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(18)
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

struct GlobalFriendRoomDirectorySheet: View {
    let onStatusMessage: (String) -> Void
    @ObservedObject private var friendWorkoutManager = FriendWorkoutManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedFilter: FriendWorkoutContext?
    @State private var joinCode = ""

    init(initialContext: FriendWorkoutContext? = nil, onStatusMessage: @escaping (String) -> Void) {
        self.onStatusMessage = onStatusMessage
        _selectedFilter = State(initialValue: initialContext)
    }

    private var displayedRooms: [FriendWorkoutRoom] {
        let rooms = friendWorkoutManager.globalRooms.sorted(by: { $0.scheduleDate < $1.scheduleDate })
        guard let selectedFilter else { return rooms }
        return rooms.filter { $0.context == selectedFilter }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Public CloudKit rooms are visible to everyone. Join instantly with a room code or from the directory.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)

                HStack(spacing: 8) {
                    filterChip(label: "All", selected: selectedFilter == nil) {
                        selectedFilter = nil
                    }
                    ForEach(FriendWorkoutContext.allCases, id: \.self) { context in
                        filterChip(label: context.title, selected: selectedFilter == context) {
                            selectedFilter = context
                        }
                    }
                }

                HStack(spacing: 8) {
                    TextField("Enter room code", text: $joinCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                        .padding(10)
                        .background(Color(hex: "F8FAFC"))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    Button("Join") {
                        Task {
                            let success = await friendWorkoutManager.joinRoom(withCode: joinCode)
                            let normalized = normalizedRoomCode(joinCode)
                            if success {
                                joinCode = ""
                                onStatusMessage("Joined room \(normalized).")
                            } else {
                                onStatusMessage(friendWorkoutManager.syncErrorMessage ?? "Unable to join that room.")
                            }
                        }
                    }
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.bluePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                if displayedRooms.isEmpty {
                    Text("No public rooms available right now.")
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(hex: "F8FAFC"))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(displayedRooms) { room in
                                HStack(spacing: 10) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(room.title)
                                            .font(AppTheme.Typography.telemetry(size: 15, weight: .semibold))
                                        Text("\(room.contextLabel) • \(room.scheduleLabel)")
                                            .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                        Text("Code \(room.roomCode)")
                                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.Colors.bluePrimary)
                                    }

                                    Spacer()

                                    Button(room.joined ? "Leave Room" : "Join Room") {
                                        Task {
                                            let success = await friendWorkoutManager.toggleMembership(room: room)
                                            if success {
                                                onStatusMessage(room.joined ? "You left \(room.title)." : "You joined \(room.title).")
                                            } else {
                                                onStatusMessage(friendWorkoutManager.syncErrorMessage ?? "Unable to update room membership.")
                                            }
                                        }
                                    }
                                    .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                                    .foregroundColor(room.joined ? AppTheme.Colors.bluePrimary : .white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(room.joined ? Color(hex: "E8F3FF") : AppTheme.Colors.bluePrimary)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
                        .padding(.vertical, 2)
                    }
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Global Rooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await friendWorkoutManager.refreshGlobalDirectory()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    }
                }
            }
            .task {
                await friendWorkoutManager.refreshGlobalDirectory()
            }
        }
    }

    private func filterChip(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppTheme.Typography.telemetry(size: 12, weight: .semibold))
                .foregroundColor(selected ? .white : AppTheme.Colors.bluePrimary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(selected ? AppTheme.Colors.bluePrimary : Color(hex: "E8F3FF"))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func normalizedRoomCode(_ value: String) -> String {
        String(value.uppercased().filter { $0.isLetter || $0.isNumber })
    }
}

struct CreateFriendRoomSheet: View {
    let context: FriendWorkoutContext
    let onCreate: (String, Date, Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var roomName = ""
    @State private var scheduleDate = Date().addingTimeInterval(3600)
    @State private var isPublicRoom = true

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 14) {
                Text("Create a \(context == .program ? "Program" : "Gym") room and invite people to train together.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Room Name")
                        .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                    TextField("Evening Strength Crew", text: $roomName)
                        .font(AppTheme.Typography.telemetry(size: 15, weight: .medium))
                        .padding(10)
                        .background(Color(hex: "F8FAFC"))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Schedule")
                        .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                    DatePicker("", selection: $scheduleDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }

                Toggle(isOn: $isPublicRoom) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("List in global directory")
                            .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                        Text("Anyone can discover and join this room by code.")
                            .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .toggleStyle(.switch)

                Spacer()
            }
            .padding(16)
            .navigationTitle("New Friend Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") {
                        onCreate(roomName, scheduleDate, isPublicRoom)
                        dismiss()
                    }
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                }
            }
        }
    }
}

#Preview {
    ProgramView()
        .environmentObject(StoreKitManager.shared)
}
