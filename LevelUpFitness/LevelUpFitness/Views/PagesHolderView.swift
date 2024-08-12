//
//  PagesHolderView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI

struct PagesHolderView: View {
    @StateObject var programManager = ProgramManager()
    @StateObject var databaseManager = DatabaseManager()
    @StateObject var healthManager = HealthManager()
    @StateObject var badgeManager = BadgeManager()
    @StateObject var xpManager = XPManager()
    @StateObject var exerciseManager = ExerciseManager()
    
    @State var pageType: PageType
    
    var body: some View {
        ZStack {
            VStack {
                switch pageType {
                case .home:
                    HomeView(programManager: programManager, databaseManager: databaseManager, healthManager: healthManager, xpManager: xpManager, exerciseManager: exerciseManager, pageType: $pageType)
                        .preferredColorScheme(.light)
                case .program:
                    ProgramView(programManager: programManager, badgeManager: badgeManager, xpManager: xpManager)
                        .preferredColorScheme(.light)
                case .library:
                    LibraryView(programManager: programManager, xpManager: xpManager, exerciseManager: exerciseManager)
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
    }
}

#Preview {
    PagesHolderView(pageType: .home)
}
