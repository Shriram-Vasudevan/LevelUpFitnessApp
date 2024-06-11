//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI

struct ProgramView: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var badgeManager: BadgeManager
    
    @State var navigateToWorkoutView: Bool = false
    @State var navigateToMetricsView: Bool = false
    
    @State var buttonHeight: CGFloat = 200
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(.all)
                
                VStack (spacing: 0) {
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .foregroundColor(.white)
                            .frame(width: 20, height: 15)
                            .hidden()
                        
                        Spacer()
                        
                        Text("Your Program")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .foregroundColor(.white)
                           // .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                    }
                    .padding(.horizontal)
                    
                    if storageManager.program == nil && !storageManager.retrievingProgram {
                        VStack {
                            HStack {
                                Text("No Program Found \n Select One Below!")
                                    .font(.custom("Sailec Medium", size: 20))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.black)
                                
                                Spacer()
                            }
                            .padding()
                            
                            if let standardProgramNames = storageManager.standardProgramNames {
                                
                                ForEach(standardProgramNames, id: \.self) { name in
                                    HStack {
                                        Text(name)
                                            .font(.custom("EtruscoNowCondensed Bold", size: 20))
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            Task {
                                                await storageManager.joinStandardProgram(programName: name, badgeManager: badgeManager)
                                            }
                                        }, label: {
                                            Text("Join")
                                                .bold()
                                        })
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.white)
                                            .shadow(radius: 5)
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            Spacer()
                        }
                        .background(
                            Rectangle()
                                .fill(.white)
                        )
                        .ignoresSafeArea(.all)
                    } else {
                        VStack {
                            ScrollView(.vertical) {
                                VStack (spacing: 0) {
                                    ProgramListWidget(storageManager: storageManager, navigateToWorkoutView: $navigateToWorkoutView)
                                        .padding(.top)
                                       
                                    GeometryReader { geometry in
                                        let totalWidth = geometry.size.width
                                        let padding: CGFloat = 10
                                        let squareWidth = (totalWidth - padding) / 2
                                        
                                        HStack(spacing: padding) {
                                            Button(action: {
                                                
                                            }, label: {
                                                Rectangle()
                                                    .fill(.white)
                                                    .frame(width: squareWidth, height: squareWidth)
                                                    .shadow(radius: 5)
                                                    .overlay (
                                                        Text("Message \nLuke")
                                                            .font(.custom("Sailec Bold", size: 25))
                                                            .multilineTextAlignment(.leading)
                                                            .foregroundColor(.black)
                                                            .padding(),
                                                        alignment: .topLeading
                                                    )
                                                    .overlay (
                                                        Image("Chat")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 40, height: 40)
                                                            .padding(),
                                                        alignment: .bottomTrailing
                                                    )
                                            })
                                            
                                            Button(action: {
                                                navigateToMetricsView = true
                                            }, label: {
                                                Rectangle()
                                                    .fill(.white)
                                                    .frame(width: squareWidth, height: squareWidth)
                                                    .shadow(radius: 5)
                                                    .overlay (
                                                        Text("Your \nMetrics")
                                                            .font(.custom("Sailec Bold", size: 25))
                                                            .multilineTextAlignment(.leading)
                                                            .foregroundColor(.black)
                                                            .padding(),
                                                        alignment: .topLeading
                                                    )
                                                    .overlay (
                                                        Image("PieChart")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 60, height: 60)
                                                            .padding(),
                                                        alignment: .bottomTrailing
                                                    )
                                            })
                                        }
                                    }
                                    .frame(height: (UIScreen.main.bounds.width - 10) / 2)
                                    .padding(.horizontal)
                                    
                                    HStack {
                                        Text("Achievements")
                                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(badgeManager.badges.sorted(by: { $0.badgeCriteria.threshold < $1.badgeCriteria.threshold }), id: \.id) { badge in
                                        
                                        if let userBadgeInfo = badgeManager.userBadgeInfo {
                                            if !userBadgeInfo.badgesEarned.contains(badge.id) {
                                                AchievementWidget(userBadgeInfo: userBadgeInfo, badge: badge)
                                                    .padding(.bottom)
                                            }
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .background(
                            Rectangle()
                                .fill(.white)
                        )
                        .ignoresSafeArea(.all)
                    }
                }
            }
            .fullScreenCover(isPresented:  $navigateToWorkoutView, content: {
                WorkoutView(storageManager: storageManager, onStartSet: {int1 in}, onDataEntryCompleteHandler: { string1, string2, string3, int  in })
            })
            .fullScreenCover(isPresented:  $navigateToMetricsView, content: {
                if let program = storageManager.program {
                    ProgramStatisticsView(program: program)
                }
            })
//            .navigationDestination(isPresented: $navigateToWorkoutView, destination: {
//                WorkoutView(storageManager: storageManager)
//            })
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    ProgramView(storageManager: StorageManager(), badgeManager: BadgeManager())
}

