//
//  GymSessionView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct GymSessionsView: View {
    @ObservedObject var gymManager = GymManager.shared
    @ObservedObject var friendWorkoutManager = FriendWorkoutManager.shared
    @EnvironmentObject private var storeKitManager: StoreKitManager

    @State private var showEndSessionConfirmation = false
    @State private var navigateToExerciseView = false
    @State private var navigateToPastSessionDetailView = false
    @State private var navigateToAddExerciseView = false
    @State private var navigateToAllPastSessionsView = false
    @State private var selectedExerciseRecord: ExerciseRecord?
    @State private var selectedPastSession: GymSession?

    @State var showGymSessionInfoSheet: Bool = false
    @State private var expandedExercises: Set<UUID> = []
    @State private var showPaywall = false
    // Stopwatch Animation State
    @State private var isPulsing = false
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    
                    if let currentSession = gymManager.currentSession {
                        activeGymSessionView(currentSession)
                    } else {
                        beginSessionCTA
                    }
                    
                    pastSessionsSection
                    
                    if !gymManager.gymSessions.isEmpty {
                        gymStatsSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 120) // Tab bar clearance
            }

            if showEndSessionConfirmation {
                Color.black.opacity(0.4).ignoresSafeArea()
                    .onTapGesture { showEndSessionConfirmation = false }
                
                VStack(spacing: 24) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(AppTheme.Colors.danger)
                    
                    Text("End Session?")
                        .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    
                    HStack(spacing: 12) {
                        PremiumActionButton(title: "Cancel", action: { showEndSessionConfirmation = false }, style: .secondary)
                        PremiumActionButton(title: "End Session", action: {
                            showEndSessionConfirmation = false
                            gymManager.endGymSession()
                        }, style: .primary)
                    }
                }
                .padding(24)
                .background(AppTheme.Colors.surfaceLight)
                .clipShape(AngledCutShape(cutSize: 24))
                .shadow(color: Color.black.opacity(0.2), radius: 20)
                .padding(.horizontal, 40)
            }
        }
        .navigationDestination(isPresented: $navigateToExerciseView) {
            if let target = selectedExerciseRecord { GymSessionExerciseView(exerciseRecord: target) }
        }
        .navigationDestination(isPresented: $navigateToPastSessionDetailView) {
            if let target = selectedPastSession { PastGymSessionDetailView(session: target) }
        }
        .navigationDestination(isPresented: $navigateToAddExerciseView) {
            AddExerciseView(onAddExercise: { record in gymManager.currentSession?.addIndividualExercise(exerciseRecord: record) })
        }
        .navigationDestination(isPresented: $navigateToAllPastSessionsView) {
            AllPastGymSessionsView(gymManager: gymManager)
        }
        .sheet(isPresented: $showGymSessionInfoSheet) { GymSessionInfoView() }
        .sheet(isPresented: $showGymSessionInfoSheet) { GymSessionInfoView() }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(allowDismissal: true) { showPaywall = false }
                .environmentObject(storeKitManager)
        }
        .task { await friendWorkoutManager.refreshIfNeeded(context: .gym) }
    }

    // MARK: - Premium UI Components
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Live Gym")
                    .font(AppTheme.Typography.telemetry(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(gymManager.currentSession == nil ? "Ready to start workout." : "Session active. Recording data.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            
            Button { showGymSessionInfoSheet = true } label: {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(KineticButtonStyle())
        }
    }

    private var beginSessionCTA: some View {
        VStack(spacing: 20) {
            Image(systemName: "power.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.2))
            
            
            Button {
                gymManager.startGymSession()
            } label: {
                HStack(spacing: 8) {
                    Text("START SESSION")
                        .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    Image(systemName: "play.fill")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(AppTheme.Colors.backgroundDark)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppTheme.Colors.success)
                .clipShape(AngledCutShape(cutSize: 12))
            }
            .buttonStyle(KineticButtonStyle())
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(AngledCutShape(cutSize: 24))
        .overlay(AngledCutShape(cutSize: 24).stroke(Color.black.opacity(0.02), lineWidth: 1))
    }

    private func activeGymSessionView(_ session: GymSession) -> some View {
        VStack(spacing: 32) {
            Text("SESSION ACTIVE")
                .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.bluePrimary)
                .textCase(.uppercase)

            // Massive Visual Stopwatch Ring
            ZStack {
                Circle()
                    .stroke(AppTheme.Colors.bluePrimary.opacity(0.1), lineWidth: 16)
                    .frame(width: 200, height: 200)

                Circle()
                    .trim(from: 0, to: isPulsing ? 1.0 : 0.0)
                    .stroke(AppTheme.Colors.bluePrimary, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 60).repeatForever(autoreverses: false), value: isPulsing)
                
                VStack(spacing: 4) {
                    Text(gymManager.elapsedTime)
                        .font(AppTheme.Typography.monumentalNumber(size: 40))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                    Text("Time Elapsed")
                        .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                }
            }
            .onAppear { isPulsing = true }
            .onDisappear { isPulsing = false }
            
            HStack(spacing: 16) {
                PremiumActionButton(title: "Log Exercise", icon: "plus", action: { navigateToAddExerciseView = true }, style: .secondary)
                PremiumActionButton(title: "End Session", icon: "stop.fill", action: { showEndSessionConfirmation = true }, style: .destructive)
            }
            
            if !session.allExercises.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Logged Exercises")
                        .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                        .textCase(.uppercase)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(session.allExercises) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                let name = switch record.exerciseInfo {
                                case .programExercise(let prog): prog.name
                                case .libraryExercise(let lib): lib.name
                                }
                                Text(name)
                                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Text("\(record.exerciseData.sets.count) Sets Logged")
                                    .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.bluePrimary)
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.Colors.success)
                        }
                        .padding()
                        .background(AppTheme.Colors.backgroundDark)
                        .clipShape(AngledCutShape(cutSize: 12))
                        .overlay(AngledCutShape(cutSize: 12).stroke(Color.black.opacity(0.05), lineWidth: 1))
                    }
                }
            }
        }
        .padding(24)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(AngledCutShape(cutSize: 24))
        .overlay(AngledCutShape(cutSize: 24).stroke(Color.black.opacity(0.02), lineWidth: 1))
    }

    // Removed tacticalTeamSection

    private var pastSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Past Sessions")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
                Spacer()
                Button("Archive") { navigateToAllPastSessionsView = true }
                    .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }

            if gymManager.gymSessions.isEmpty {
                Text("No past sessions found.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(AngledCutShape(cutSize: 16))
                    .overlay(AngledCutShape(cutSize: 16).stroke(Color.black.opacity(0.02), lineWidth: 1))
            } else {
                ForEach(gymManager.gymSessions.prefix(3), id: \.id) { session in
                    Button {
                        selectedPastSession = session
                        navigateToPastSessionDetailView = true
                    } label: {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.startTime, style: .date)
                                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Text("\(session.allExercises.count) Exercises Logged")
                                    .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            Spacer()
                            Text(timeFormatted(session.duration ?? 0))
                                .font(AppTheme.Typography.monumentalNumber(size: 14))
                                .foregroundColor(AppTheme.Colors.bluePrimary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding()
                        .background(AppTheme.Colors.surfaceLight)
                        .clipShape(AngledCutShape(cutSize: 16))
                        .overlay(AngledCutShape(cutSize: 16).stroke(Color.black.opacity(0.02), lineWidth: 1))
                    }
                    .buttonStyle(KineticButtonStyle())
                }
            }
        }
    }

    private var gymStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All-Time Stats")
                .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
            
            HStack(spacing: 12) {
                statBox(title: "Sessions", value: "\(gymManager.gymSessions.count)")
                statBox(title: "Time (Hrs)", value: String(format: "%.1f", (gymManager.gymSessions.reduce(0) { $0 + ($1.duration ?? 0) }) / 3600))
            }
        }
    }

    private func statBox(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(AppTheme.Typography.monumentalNumber(size: 24))
                .foregroundColor(AppTheme.Colors.bluePrimary)
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(AngledCutShape(cutSize: 16))
        .overlay(AngledCutShape(cutSize: 16).stroke(Color.black.opacity(0.02), lineWidth: 1))
    }

    private func timeFormatted(_ totalSeconds: TimeInterval) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = (Int(totalSeconds) / 60) % 60
        let hours = Int(totalSeconds) / 3600
        if hours > 0 { return String(format: "%02d:%02d:%02d", hours, minutes, seconds) }
        else { return String(format: "%02d:%02d", minutes, seconds) }
    }
}

#Preview {
    GymSessionsView()
}
