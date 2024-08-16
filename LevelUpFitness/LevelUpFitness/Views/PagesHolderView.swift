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
                        challengeManager: challengeManager,
                        pageType: $pageType
                    )
                    .preferredColorScheme(.light)
                case .program:
                    ProgramView(
                        programManager: programManager,
                        badgeManager: badgeManager,
                        xpManager: xpManager
                    )
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
                                pageType = .program
                            }, label: {
                                VStack {
                                    Image(pageType == .program ? "TrainBlue" : "TrainGrey")
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
                    
                async let userProgram: ()? = programManager.program == nil ? programManager.getUserProgram(badgeManager: badgeManager) : nil
                
                _ = await (userProgram)
            }
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
