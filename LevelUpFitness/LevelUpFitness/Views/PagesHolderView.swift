//
//  PagesHolderView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI

struct PagesHolderView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var healthManager = HealthManager.shared
    @ObservedObject var badgeManager = BadgeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var exerciseManager = ExerciseManager.shared
    @ObservedObject var challengeManager = ChallengeManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var toDoListManager = ToDoListManager.shared
    @ObservedObject var globalCoverManager = GlobalCoverManager.shared
    
    var notificationManager = NotificationManager.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var pageType: PageType
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                AppTheme.Colors.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    switch pageType {
                    case .home:
                        HomeView(
                            pageType: $pageType
                        )
                    case .levelBreakdown:
                        FullLevelBreakdownView()
                    case .program:
                        ProgramView()
                    case .gymSession:
                        GymSessionsView()
                    case .exercise:
                        LibraryView(
                            programManager: programManager,
                            xpManager: xpManager,
                            exerciseManager: exerciseManager
                        )
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Floating Tab Bar
                EngineeredTabBar(pageType: $pageType)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .preferredColorScheme(.dark)
            .onAppear {
                Task {
                    if await HealthManager.shared.todaysSteps == nil {
                        await HealthManager.shared.getInitialHealthData()
                    }
                }
            }
            .fullScreenCover(isPresented: $globalCoverManager.showProgramDayCompletionCover) {
                ProgramCompletedForTheDayCover()
            }
            .fullScreenCover(isPresented: $globalCoverManager.showProgramCompletionCover) {
                ProgramCompletedCover()
            }
            .fullScreenCover(isPresented: $globalCoverManager.showChallengeCompletionCover) {
                ChallengeCompletedView()
            }
            .ignoresSafeArea(edges: .bottom)
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    NotificationManager.shared.appDidBecomeActive()
                } else if newPhase == .inactive {
                    Task {
                        if XPManager.shared.xpDataModified {
                            await XPManager.shared.addXPToDB()
                        }
                    }
                    print("Inactive")
                } else if newPhase == .background {
                    Task {
                        if XPManager.shared.xpDataModified {
                            await XPManager.shared.addXPToDB()
                        }
                    }
                    NotificationManager.shared.appDidEnterBackground()
                }
            }
        }
        
    }
}

// MARK: - Engineered floating Tab Bar
struct EngineeredTabBar: View {
    @Binding var pageType: PageType
    
    // Smooth transition namespace for the active indicator
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            tabItem(for: .home, icon: "house.fill", title: "Home")
            tabItem(for: .levelBreakdown, icon: "chart.bar.fill", title: "Level")
            tabItem(for: .program, icon: "list.bullet.clipboard.fill", title: "Program")
            tabItem(for: .gymSession, icon: "dumbbell.fill", title: "Gym")
            tabItem(for: .exercise, icon: "figure.cross.training", title: "Library")
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial)
        .background(AppTheme.Colors.backgroundSurface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.macroRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Geometry.macroRadius, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 20, x: 0, y: 10)
    }
    
    @ViewBuilder
    private func tabItem(for type: PageType, icon: String, title: String) -> some View {
        let isActive = pageType == type
        
        Button {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2)) {
                pageType = type
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? AppTheme.Colors.bluePrimary : AppTheme.Colors.textSecondary)
                    .frame(height: 24)
                    .controlledGlow(isActive: isActive) // subtle blue glow if active
                
                Text(title)
                    .font(AppTheme.Typography.telemetry(size: 10, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? .white : AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous)
                            .fill(AppTheme.Colors.bluePrimary.opacity(0.1))
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PagesHolderView(pageType: .home)
        .environmentObject(StoreKitManager.shared)
}
