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
    @StateObject var xpManager = XPManager()
    
    @State var pageType: PageType
    
    var body: some View {
        ZStack {
            VStack {
                switch pageType {
                case .home:
                    HomeView(storageManager: storageManager, databaseManager: databaseManager, healthManager: healthManager, xpManager: xpManager, pageType: $pageType)
                        .preferredColorScheme(.light)
                case .program:
                    ProgramView(storageManager: storageManager, badgeManager: badgeManager, xpManager: xpManager)
                        .preferredColorScheme(.light)
                case .profile:
                    Text("Workout")
                case .library:
                    LibraryView(storageManager: storageManager)
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
                                pageType = .library
                            }, label: {
                                VStack {
                                    Image(pageType == .library ? "LibraryBlue" : "LibraryGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                        .foregroundColor(pageType == .library ? .blue : .gray)
                                    
                                    
                                    Text("Library")
                                        .font(.caption)
                                        .foregroundColor(pageType == .library  ? .blue : .gray)
                                    
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
                async let userProgram: ()? = storageManager.program == nil ? storageManager.getUserProgram(badgeManager: badgeManager) : nil
                async let exercises: ()? = storageManager.downloadExercises() 
                
                _ = await (dailyVideo, userProgram, exercises)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    PagesHolderView(pageType: .home)
}
