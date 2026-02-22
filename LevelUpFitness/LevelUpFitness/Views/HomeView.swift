//
//  HomeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var healthManager = HealthManager.shared
    @ObservedObject var badgeManager = BadgeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var exerciseManager = ExerciseManager.shared
    @ObservedObject var challengeManager = ChallengeManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var toDoListManager = ToDoListManager.shared

    @Binding var pageType: PageType

    @State private var showLevelUpInformationView = false
    @State private var selectedExercise: Progression?
    @State private var healthStatType: String = ""
    @State private var navigateToHealthStatTrendView = false
    @State private var navigateToWeightTrendView = false
    @State private var navigateToProfileView = false
    @State private var navigateToAvailableChallengesView = false
    @State private var perfectProgramChallengeStartFailed = false
    @State private var showChallengeDetailsCover = false
    @State private var userChallenge: UserChallenge?
    @State private var showToDoList = true

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    premiumHeroHeader
                    
                    quickActionsGrid
                    
                    if showToDoList {
                        todoEngineeredSection
                    }
                    HStack {
                        Spacer()
                    }
                    activeProgramsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120) // Tab bar clearance
            }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $navigateToHealthStatTrendView) { HealthTrendView(healthStatType: healthStatType) }
        .navigationDestination(isPresented: $navigateToProfileView) { ProfileView() }
        .fullScreenCover(isPresented: $showLevelUpInformationView) { LevelInfoView() }
        .fullScreenCover(isPresented: $navigateToAvailableChallengesView) { ActiveChallengesView() }
        .fullScreenCover(isPresented: $navigateToWeightTrendView) { WeightTrendView() }
        .navigationDestination(item: $selectedExercise) { exercise in IndividualExerciseView(progression: exercise) }
        .fullScreenCover(isPresented: $showChallengeDetailsCover) {
            if let userChallenge {
                ChallengeDetailsView(challenge: userChallenge, currentProgress: challengeProgress(for: userChallenge))
            }
        }
    }

    // MARK: - Premium Hero Header
    private var premiumHeroHeader: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(AppTheme.Typography.telemetry(size: 28, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Text(InitializationManager.shared.selectedAffirmation ?? "Ready to train.")
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }

                Spacer()

                Button {
                    navigateToProfileView = true
                } label: {
                    profileImage
                }
                .buttonStyle(KineticButtonStyle())
            }

            // High-fidelity Stats Bar
            HStack(spacing: 12) {
                heroDataBlock(title: "Level", value: "\(xpManager.userXPData?.level ?? 1)", action: { pageType = .levelBreakdown })
                heroDataBlock(title: "Programs", value: "\(programManager.userProgramData.count)", action: { pageType = .program })
                heroDataBlock(title: "Challenges", value: "\(challengeManager.userChallenges.count)", action: { navigateToAvailableChallengesView = true })
            }
        }
    }
    
    // MARK: - Core Reusable Blocks
    private func heroDataBlock(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(AppTheme.Typography.telemetry(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)

                Text(value)
                    .font(AppTheme.Typography.monumentalNumber(size: 28))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppTheme.Colors.surfaceLight)
            .clipShape(AngledCutShape(cutSize: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
            .overlay(
                AngledCutShape(cutSize: 12)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
        }
        .buttonStyle(KineticButtonStyle())
    }

    private var profileImage: some View {
        Group {
            if let pfp = AuthenticationManager.shared.pfp, let uiImage = UIImage(data: pfp) {
                Image(uiImage: uiImage).resizable().scaledToFill()
            } else {
                Image("NoProfile").resizable().scaledToFill()
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }

    // MARK: - Tactical Actions Grid
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack(spacing: 12) {
                actionTile(title: "Schedule", icon: "calendar", primary: true, action: { pageType = .program })
                actionTile(title: "Live Gym", icon: "dumbbell.fill", primary: false, action: { pageType = .gymSession })
                actionTile(title: "Library", icon: "book.fill", primary: false, action: { pageType = .exercise })
            }
        }
    }
    
    private func actionTile(title: String, icon: String, primary: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(primary ? .white : AppTheme.Colors.bluePrimary)
                
                Text(title)
                    .font(AppTheme.Typography.telemetry(size: 13, weight: .bold))
                    .foregroundColor(primary ? .white : AppTheme.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(primary ? AppTheme.Colors.bluePrimary : AppTheme.Colors.surfaceLight)
            .clipShape(AngledCutShape(cutSize: 16))
            .shadow(color: primary ? AppTheme.Colors.bluePrimary.opacity(0.3) : Color.black.opacity(0.04), radius: primary ? 12 : 6, x: 0, y: primary ? 6 : 2)
            .overlay(
                AngledCutShape(cutSize: 16)
                    .stroke(Color.black.opacity(0.02), lineWidth: 1)
            )
        }
        .buttonStyle(KineticButtonStyle())
    }

    // MARK: - Engineered To-Do Section
    private var todoEngineeredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Tasks")
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Button(action: {
                    withAnimation { showToDoList.toggle() }
                }) {
                    Image(systemName: "chevron.up")
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .font(.system(size: 14))
                }
            }
            
            if toDoListManager.toDoList.isEmpty {
                Text("All tasks complete.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(AngledCutShape(cutSize: 12))
                    .overlay(AngledCutShape(cutSize: 12).stroke(Color.black.opacity(0.02), lineWidth: 1))
            } else {
                VStack(spacing: 10) {
                    ForEach(toDoListManager.toDoList.prefix(3)) { item in
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation { toDoListManager.toggleToDoCompletion(item: item) }
                            }) {
                                Image(systemName: item.completed ? "checkmark.square.fill" : "square")
                                    .font(.system(size: 20))
                                    .foregroundColor(item.completed ? AppTheme.Colors.success : AppTheme.Colors.textSecondary)
                            }
                            .buttonStyle(KineticButtonStyle())

                            Text(item.description)
                                .font(AppTheme.Typography.telemetry(size: 15, weight: .medium))
                                .foregroundColor(item.completed ? AppTheme.Colors.textSecondary : AppTheme.Colors.textPrimary)
                                .strikethrough(item.completed, color: AppTheme.Colors.textSecondary)
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(item.completed ? AppTheme.Colors.backgroundDark : AppTheme.Colors.surfaceLight)
                        .clipShape(AngledCutShape(cutSize: 12))
                        .overlay(AngledCutShape(cutSize: 12).stroke(Color.black.opacity(0.02), lineWidth: 1))
                    }
                }
            }
        }
    }

    // MARK: - Metrics Showcase
    private var metricsShowcaseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Stats")
                .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            HStack(spacing: 12) {
                metricRing(title: "Steps", value: "\(healthManager.todaysSteps?.count ?? 0)", icon: "shoeprints.fill", color: AppTheme.Colors.bluePrimary, goal: 10000)
                metricRing(title: "Kcal", value: "\(healthManager.todaysCalories?.count ?? 0)", icon: "flame.fill", color: AppTheme.Colors.danger, goal: 500)
            }
        }
    }

    private func metricRing(title: String, value: String, icon: String, color: Color, goal: Double) -> some View {
        let currentValue = Double(value) ?? 0
        let progress = min(currentValue / goal, 1.0)
        
        return VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.1), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            .frame(width: 60, height: 60)
            
            VStack(spacing: 2) {
                Text(value)
                    .font(AppTheme.Typography.monumentalNumber(size: 16))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text(title)
                    .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(AngledCutShape(cutSize: 16))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .overlay(AngledCutShape(cutSize: 16).stroke(Color.black.opacity(0.02), lineWidth: 1))
    }

    // MARK: - Active Programs Section
    private var activeProgramsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Start today's program")
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Spacer()
                Button("View All") { pageType = .program }
                    .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }
            
            if programManager.userProgramData.isEmpty {
                Text("No active programs found.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(height: 100)
                    .frame(maxWidth: .infinity)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(AngledCutShape(cutSize: 12))
                    .overlay(AngledCutShape(cutSize: 12).stroke(Color.black.opacity(0.02), lineWidth: 1))
            } else {
                ForEach(programManager.userProgramData.prefix(2), id: \.programID) { program in
                    HStack(spacing: 16) {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                            .frame(width: 48, height: 48)
                            .background(AppTheme.Colors.bluePrimary.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(program.program.programName)
                                .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            Text("\(program.program.programDuration) Days")
                                .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(16)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(AngledCutShape(cutSize: 16))
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                    .overlay(AngledCutShape(cutSize: 16).stroke(Color.black.opacity(0.02), lineWidth: 1))
                }
            }
        }
    }

    // MARK: - Helpers
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Morning." }
        else if hour < 17 { return "Afternoon." }
        else { return "Evening." }
    }
}

// Challenge Progress Helper
extension HomeView {
    func challengeProgress(for challenge: UserChallenge) -> Int {
        return challenge.startValue
    }
}

#Preview {
    HomeView(pageType: .constant(.home))
}

struct AngledCutShape: Shape {
    var cutSize: CGFloat = 16
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: cutSize, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cutSize))
        path.addLine(to: CGPoint(x: rect.maxX - cutSize, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: cutSize))
        path.closeSubpath()
        return path
    }
}

