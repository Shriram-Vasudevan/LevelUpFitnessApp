//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct ProgramView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var challengeManager = ChallengeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var friendWorkoutManager = FriendWorkoutManager.shared

    @State private var navigateToWorkoutView = false
    @State private var showProgramHub = false
    @State private var showJoinPopup = false
    @State private var selectedStandardProgramDBRepresentation: StandardProgramDBRepresentation?
    @State private var selectedDate = Date()
    @State private var showFriendRoomComposer = false
    @State private var showGlobalRoomDirectory = false
    @State private var infoMessage: String?
    @State private var showInfoAlert = false
    @State private var navigateToAvailableChallengesView = false

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    
                    if !programManager.userProgramData.isEmpty {
                        activeProgramsCarousel
                    } else {
                        emptyProgramsState
                    }

                    if let selectedProgram = programManager.selectedProgram?.program {
                        workspaceSection(selectedProgram)
                    } else {
                        discoverWorkspace
                    }
                }
                .padding(.vertical, 16)
                .padding(.bottom, 120)
            }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $navigateToWorkoutView) {
            WorkoutView(programManager: programManager, xpManager: xpManager)
        }
        .fullScreenCover(isPresented: $navigateToAvailableChallengesView) {
            ActiveChallengesView() // Legacy view but keeping navigation intact
        }
        .sheet(isPresented: $showFriendRoomComposer) {
            CreateFriendRoomSheet(context: .program) { title, date, isPublic in
                Task {
                    let success = await friendWorkoutManager.createRoom(
                        context: .program, title: title, scheduleDate: date, isPublic: isPublic
                    )
                    infoMessage = success ? "Tactical team room synchronized." : "Failed to provision room."
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
        .sheet(isPresented: $showProgramHub) {
            // Native sheet for program management hub
            VStack {
                Text("Program Hub")
                    .font(AppTheme.Typography.telemetry(size: 24, weight: .bold))
                Spacer()
            }
            .padding()
        }
        .alert("Program Information", isPresented: $showInfoAlert) {
            Button("Acknowledged", role: .cancel) { }
        } message: {
            Text(infoMessage ?? "")
        }
        .task { await initializeProgramData() }
    }

    // MARK: - App Architecture Components
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Programs")
                    .font(AppTheme.Typography.telemetry(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Active training schedules.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            
            Button(action: { showProgramHub = true }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(KineticButtonStyle())
        }
        .padding(.horizontal, 20)
    }

    private var emptyProgramsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.dashed")
                .font(.system(size: 32))
                .foregroundColor(AppTheme.Colors.textSecondary)
            Text("No active programs detected.")
                .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(AngledCutShape(cutSize: 20))
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func programTabBackgroundImage(_ imageName: String) -> some View {
        if let url = URL(string: imageName), url.scheme == "https" {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Image("LevelUpFitnessLogo").resizable().aspectRatio(contentMode: .fill)
                }
            }
        } else {
            Image("LevelUpFitnessLogo").resizable().aspectRatio(contentMode: .fill)
        }
    }

    @ViewBuilder
    private func programTabContentOverlay(name: String, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: isSelected ? "bolt.fill" : "bolt")
                    .foregroundColor(.white)
                Spacer()
                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
            }
            Spacer()
            Text(name)
                .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
    }

    private func activeProgramTab(for protocolData: ProgramWithID, isSelected: Bool) -> some View {
        ZStack(alignment: .leading) {
            programTabBackgroundImage(protocolData.program.imageName)
                .frame(width: 160, height: 160)
                .overlay(LinearGradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.2)], startPoint: .bottom, endPoint: .top))
                .overlay(Color.blue.opacity(isSelected ? 0.0 : 0.4))
                .overlay(Color.black.opacity(isSelected ? 0.0 : 0.4))

            programTabContentOverlay(name: protocolData.program.programName, isSelected: isSelected)
        }
        .frame(width: 160, height: 160)
        .clipShape(AngledCutShape(cutSize: 16))
        .shadow(color: isSelected ? AppTheme.Colors.bluePrimary.opacity(0.3) : Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
        .overlay(
            AngledCutShape(cutSize: 16)
                .stroke(isSelected ? Color.white.opacity(0.4) : Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    private var activeProgramsCarousel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Engagements")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                Text("\(programManager.userProgramData.count) SYNCHRONIZED")
                    .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(programManager.userProgramData, id: \.programID) { programData in
                        let isSelected = programManager.selectedProgram?.programID == programData.programID
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                programManager.selectedProgram = programData
                            }
                        } label: {
                            activeProgramTab(for: programData, isSelected: isSelected)
                        }
                        .buttonStyle(KineticButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
    }

    // MARK: - Workspace
    private func workspaceSection(_ program: Program) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Plan")
                .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
                .padding(.horizontal, 20)
                
            VStack(spacing: 24) {
                // High Fidelity Schedule Array
                customScheduleRing
                
                // Primary Action Execution
                PremiumActionButton(
                    title: "Execute Today's Program",
                    icon: "play.fill",
                    action: { navigateToWorkoutView = true },
                    style: .primary
                )
            }
            .padding(20)
            .background(AppTheme.Colors.surfaceLight)
            .clipShape(AngledCutShape(cutSize: 20))
            .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 20)
        }
    }

    private var customScheduleRing: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Weekly Schedule")
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Text("DAY 3")
                    .font(AppTheme.Typography.monumentalNumber(size: 14))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }
            
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack(spacing: 4) {
                        Text("D\(day + 1)")
                            .font(AppTheme.Typography.monumentalNumber(size: 10))
                            .foregroundColor(day == 2 ? .white : AppTheme.Colors.textSecondary)
                        
                        Circle()
                            .fill(day == 2 ? Color.white : (day < 2 ? AppTheme.Colors.success : AppTheme.Colors.backgroundDark))
                            .frame(width: 8, height: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(day == 2 ? AppTheme.Colors.bluePrimary : AppTheme.Colors.backgroundDark)
                    .clipShape(AngledCutShape(cutSize: 8))
                }
            }
        }
    }

    // MARK: - Discover Area
    private var discoverWorkspace: some View {
        VStack(spacing: 24) {
            tacticalTeamSection
            discoverProgramsSection("Available Programs")
        }
        .padding(.horizontal, 20)
    }
    
    // Completely Custom Team Workouts UI instead of standard blue text
    private var tacticalTeamSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Team Synchronization")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
                Spacer()
            }
            
            HStack(spacing: 12) {
                Button(action: { showFriendRoomComposer = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                        Text("Create Team")
                            .font(AppTheme.Typography.telemetry(size: 13, weight: .bold))
                    }
                    .foregroundColor(AppTheme.Colors.bluePrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(AppTheme.Colors.bluePrimary.opacity(0.1))
                    .clipShape(AngledCutShape(cutSize: 12))
                }
                .buttonStyle(KineticButtonStyle())
                
                Button(action: { showGlobalRoomDirectory = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "network")
                            .font(.system(size: 24))
                        Text("Join Team")
                            .font(AppTheme.Typography.telemetry(size: 13, weight: .bold))
                    }
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(AngledCutShape(cutSize: 12))
                    .overlay(
                        AngledCutShape(cutSize: 12)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                }
                .buttonStyle(KineticButtonStyle())
            }
        }
    }

    private func discoverProgramImage(for program: StandardProgramDBRepresentation) -> some View {
        Group {
            if let url = URL(string: program.image), url.scheme == "https" {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Rectangle()
                            .fill(AppTheme.Colors.backgroundDark)
                            .overlay(Image(systemName: "figure.cross.training").foregroundColor(AppTheme.Colors.textSecondary))
                    }
                }
            } else {
                Image("LevelUpFitnessLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(AngledCutShape(cutSize: 8))
    }

    private func discoverProgramsSection(_ title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
            
            if programManager.standardProgramDBRepresentations.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(programManager.standardProgramDBRepresentations.prefix(3), id: \.id) { program in
                        Button(action: {
                            selectedStandardProgramDBRepresentation = program
                            showJoinPopup = true
                        }) {
                            HStack(spacing: 16) {
                                discoverProgramImage(for: program)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(program.name)
                                        .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                    Text(program.environment + (program.isPremium ? " • Premium" : ""))
                                        .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            .padding(12)
                            .background(AppTheme.Colors.surfaceLight)
                            .clipShape(AngledCutShape(cutSize: 16))
                            .overlay(AngledCutShape(cutSize: 16).stroke(Color.black.opacity(0.04), lineWidth: 1))
                        }
                        .buttonStyle(KineticButtonStyle())
                    }
                }
            }
        }
    }

    private func initializeProgramData() async {
        if programManager.standardProgramDBRepresentations.isEmpty {
            await programManager.loadStandardProgramNamesAsync()
        }
        await challengeManager.fetchActiveUserChallenges()
    }
}

#Preview {
    ProgramView()
}


