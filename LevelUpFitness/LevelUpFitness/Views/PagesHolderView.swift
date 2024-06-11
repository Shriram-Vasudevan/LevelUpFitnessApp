//
//  PagesHolderView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI

struct PagesHolderView: View {
    @StateObject var storageManager = StorageManager()
    @StateObject var databaseManager = DatabaseManager()
    @StateObject var healthManager = HealthManager()
    @StateObject var badgeManager = BadgeManager()
    
    @State var pageType: PageType
    
    var body: some View {
        ZStack {
            VStack {
                switch pageType {
                case .home:
                    HomeView(storageManager: storageManager, databaseManager: databaseManager, healthManager: healthManager)
                case .program:
                    ProgramView(storageManager: storageManager, badgeManager: badgeManager)
                case .profile:
                    Text("Workout")
                case .community:
                    CommunityView()
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
                                        .foregroundColor(pageType == .home ? .blue : .gray)
                                    
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
                                        .foregroundColor(pageType == .program ? .blue : .gray)
                                    
                                    
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
                                pageType = .community
                            }, label: {
                                VStack {
                                    Image(pageType == .community ? "CommunityBlue" : "CommunityGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                        .foregroundColor(pageType == .community ? .blue : .gray)
                                    
                                    
                                    Text("Community")
                                        .font(.caption)
                                        .foregroundColor(pageType == .community  ? .blue : .gray)
                                    
                                }
                                .padding(.bottom)
                            })
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                    }
                    
                    ZStack {
                        VStack {
                            Button(action: {
                                pageType = .profile
                            }, label: {
                                VStack {
                                    Image(pageType == .profile ? "ProfileBlue" : "ProfileGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                        .foregroundColor(pageType == .profile ? .blue : .gray)
                                    
                                    
                                    Text("Profile")
                                        .font(.caption)
                                        .foregroundColor(pageType == .profile ? .blue : .gray)
                                    
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
                    
                async let dailyVideo: ()? = storageManager.dailyVideo == nil ? storageManager.downloadDailyVideo() : nil
                async let workouts = databaseManager.workouts.count <= 0 ? databaseManager.getWorkouts() : nil
                async let userProgram = storageManager.program == nil ? storageManager.getUserProgram(badgeManager: badgeManager) : nil
                
                _ = await (dailyVideo, workouts, userProgram)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    PagesHolderView(pageType: .home)
}
