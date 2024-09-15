//
//  PagesHolderView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI

struct PagesHolderView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var databaseManager = DatabaseManager.shared
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
        ZStack {
            VStack {
                switch pageType {
                case .home:
                    HomeView(
                        programManager: programManager,
                        databaseManager: databaseManager,
                        healthManager: healthManager,
                        xpManager: xpManager,
                        exerciseManager: exerciseManager,
                        challengeManager: challengeManager, levelChangeManager: levelChangeManager, toDoListManager: toDoListManager,
                        pageType: $pageType
                    )
                    .preferredColorScheme(.light)
                case .levelBreakdown:
                    FullLevelBreakdownView()
                case .program:
                    ProgramView()
                    .preferredColorScheme(.light)
                case .library:
                    LibraryView(
                        programManager: programManager,
                        xpManager: xpManager,
                        exerciseManager: exerciseManager
                    )
                    .preferredColorScheme(.light)
                }
                
                Spacer()
                                
                HStack {
                    ZStack {
                        VStack {
                            Button(action: {
                                pageType = .home
                            }, label: {
                                VStack {
                                    Image(pageType == .home ? "HomeBlue" : "HomeGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                    
                                    Text("Home")
                                        .font(.caption)
                                        .foregroundColor(pageType == .home ? .blue : .gray)
                                }
                                .padding(.bottom)
                            })
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    
                    ZStack {
                        VStack {
                            Button(action: {
                                pageType = .levelBreakdown
                            }, label: {
                                VStack {
                                    Image(pageType == .levelBreakdown ? "LevelBlue" : "LevelGray")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                    
                                    Text("Level")
                                        .font(.caption)
                                        .foregroundColor(pageType == .levelBreakdown ? .blue : .gray)
                                }
                                .padding(.bottom)
                            })
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    
                    ZStack {
                        VStack {
                            Button(action: {
                                pageType = .program
                            }, label: {
                                VStack {
                                    Image(pageType == .program ? "ProgramBlue" : "ProgramGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                    
                                    Text("Program")
                                        .font(.caption)
                                        .foregroundColor(pageType == .program ? .blue : .gray)
                                    
                                }
                                .padding(.bottom)
                            })
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }

                    ZStack {
                        VStack {
                            Button(action: {
                                pageType = .library
                            }, label: {
                                VStack {
                                    Image(pageType == .library ? "LibraryBlue" : "LibraryGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                    
                                    Text("Library")
                                        .font(.caption)
                                        .foregroundColor(pageType == .library ? .blue : .gray)
                                    
                                }
                                .padding(.bottom)
                            })
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .onAppear {
            Task {
                if healthManager.todaysSteps == nil {
                    healthManager.getInitialHealthData()
                }
                    
                async let userProgram: ()? = programManager.program.isEmpty ? programManager.getUserProgram() : nil
                async let notificationManager: () = notificationManager.identifyUser()
                async let challengeManager: () = challengeManager.challengeManagerInitialization()
                async let toDoListManager: () = toDoListManager.toDoListInit()
                async let exerciseManager: () = exerciseManager.exerciseManagerInit()
                async let xpManager: () = xpManager.xpManagerInit()
                
//                async let getUsername: () = AuthenticationManager.getUsername()
//                async let getName: () = AuthenticationManager.getName()
//
                _ = await (userProgram, notificationManager, challengeManager, toDoListManager, exerciseManager, xpManager)
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
                print("Inactive")
            } else if newPhase == .background {
                NotificationManager.shared.appDidEnterBackground()
            }
        }
    }
}

#Preview {
    PagesHolderView(pageType: .home)
}
