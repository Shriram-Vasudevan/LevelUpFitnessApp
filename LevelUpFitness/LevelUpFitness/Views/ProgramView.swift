//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI

struct ProgramView: View {
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var badgeManager: BadgeManager
    @ObservedObject var xpManager: XPManager
    
    @State var navigateToWorkoutView: Bool = false
    @State var navigateToMetricsView: Bool = false
    
    @State var buttonHeight: CGFloat = 200
    
    @Environment(\.dismiss) var dismiss
    
    @State var showConfirmationWidget: Bool = false

    @State var programPageType: ProgramPageTypes = .newProgram
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240 / 255.0, green: 244 / 255.0, blue: 252 / 255.0)
                    .ignoresSafeArea(.all)
                
                VStack (spacing: 0){
                    HStack {
                        Text("Your Program")
                            .font(.custom("EtruscoNow Medium", size: 30))
                            .bold()
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    if programManager.program == nil && !programManager.retrievingProgram {
                        VStack {
                            HStack(spacing: 0) {
                                Button(action: {
                                    programPageType = .newProgram
                                }, label: {
                                    VStack(spacing: 0) {
                                        HStack {
                                            Image("JoinProgram")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                                                
                                            
                                            Text("Join Program")
                                                .font(Font.system(size: 18))
                                                .foregroundColor(Color.black)
                                                .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 15))
                                                .fontWeight(programPageType == .newProgram ? .bold : .regular)
                                        }
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        Rectangle().fill(programPageType == .newProgram ? Color.blue : Color.clear)
                                            .frame(height: 3)
                                    }
                                })
                                
                                Button(action: {
                                    programPageType = .pastPrograms
                                }, label: {
                                    VStack(spacing: 0) {
                                        HStack {
                                            Image("PastPrograms")
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                                            
                                            Text("Past Programs")
                                                .font(Font.system(size: 18))
                                                .foregroundColor(Color.black)
                                                .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 15))
                                                .fontWeight(programPageType == .pastPrograms ? .bold : .regular)
                                        }
                                        .frame(height: 52)
                                        .frame(maxWidth: .infinity)
                                        Rectangle().fill(programPageType == .pastPrograms ? Color.blue : Color.clear)
                                            .frame(height: 3)
                                    }
                                })
                            }
                            .padding(.horizontal)
                            
                            if programPageType == .newProgram {
                                if let standardProgramNames = programManager.standardProgramNames {
                                    
                                    ForEach(standardProgramNames, id: \.self) { name in
                                        JoinProgramWidget(programName: name)
                                            .onTapGesture {
                                                Task {
                                                    await programManager.joinStandardProgram(programName: name, badgeManager: badgeManager)
                                                }
                                            }
                                    }
                                    
//                                    RequestCustomProgramWidget()
                                }
                            }
                            else if programPageType == .pastPrograms {
                                PastProgramsView(programManager: self.programManager)
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
                                    ProgramListWidget(programManager: programManager, navigateToWorkoutView: $navigateToWorkoutView)
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
                                    
                                    
                                    Button(action: {
                                        showConfirmationWidget = true
                                    }, label: {
                                        Rectangle()
                                            .fill(.white)
                                            .frame(minWidth: 0, maxWidth: .infinity)
                                            .frame(height: UIScreen.main.bounds.height / 5)
                                            .shadow(radius: 5)
                                            .overlay (
                                                Text("Leave \nProgram")
                                                    .font(.custom("Sailec Bold", size: 25))
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.black)
                                                    .padding(),
                                                alignment: .topLeading
                                            )
                                            .overlay (
                                                Image("Exit")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 60, height: 60)
                                                    .padding(),
                                                alignment: .bottomTrailing
                                            )
                                            .padding(.horizontal)
                                    })

                                    
                                    HStack {
                                        Text("Achievements")
                                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    
                                    ForEach(badgeManager.badges.sorted(by: { $0.badgeCriteria.threshold < $1.badgeCriteria.threshold }), id: \.id) { badge in
                                        
                                        if let userBadgeInfo = badgeManager.userBadgeInfo {
                                            if userBadgeInfo.badgesEarned.contains(badge.id) {
                                                AchievementWidget(userBadgeInfo: userBadgeInfo, badge: badge)
                                                    .padding(.bottom)
                                            }
                                            else {
                                                AchievementWidget(userBadgeInfo: userBadgeInfo, badge: badge)
                                                    .padding(.bottom)
                                                    .opacity(0.7)
                                            }
                                        }
                                        
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                
                if showConfirmationWidget {
                    ConfirmLeaveProgramWidget(isOpen: $showConfirmationWidget, confirmed: {
                        Task {
                            await programManager.leaveProgram()
                        }
                    })
                }
                
            }
            .fullScreenCover(isPresented:  $navigateToWorkoutView, content: {
                WorkoutView(programManager: programManager, xpManager: xpManager)
                    .preferredColorScheme(.light)
            })
            .fullScreenCover(isPresented:  $navigateToMetricsView, content: {
                if let program = programManager.program {
                    ProgramStatisticsView(program: program)
                        .preferredColorScheme(.light)
                }
            })
            .navigationBarBackButtonHidden()
        }
    }

}

struct Tab {
    var text: String
    var image: Image
}

#Preview {
    ProgramView(programManager: ProgramManager(), badgeManager: BadgeManager(), xpManager: XPManager())
}

