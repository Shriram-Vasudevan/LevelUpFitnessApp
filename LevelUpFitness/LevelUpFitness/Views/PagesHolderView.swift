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
    @State var pageType: PageType
    
    var body: some View {
        ZStack {
            VStack {
                switch pageType {
                case .home:
                    HomeView(storageManager: storageManager, databaseManager: databaseManager)
                case .train:
                    TrainView(databaseManager: databaseManager, storageManager: storageManager)
                case .profile:
                    Text("Workout")
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
                                pageType = .train
                            }, label: {
                                VStack {
                                    Image(pageType == .train ? "TrainBlue" : "TrainGrey")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .aspectRatio(contentMode:  .fill)
                                        .foregroundColor(pageType == .train ? .blue : .gray)
                                    
                                    
                                    Text("Train")
                                        .font(.caption)
                                        .foregroundColor(pageType == .train ? .blue : .gray)
                                    
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
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    PagesHolderView(pageType: .home)
}
