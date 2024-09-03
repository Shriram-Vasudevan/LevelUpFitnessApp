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
    
    @State var navigateToProgramInsightsView: Bool = false
    @State var programS3Representation: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea(.all)
                
                VStack (spacing: 0){
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
                                if let standardProgramDBRepresentations = programManager.standardProgramDBRepresentations {
                                    
                                    ForEach(standardProgramDBRepresentations, id: \.id) { standardProgramDBRepresentation in
                                        JoinProgramWidget(standardProgramDBRepresentation: standardProgramDBRepresentation)
                                            .onTapGesture {
                                                Task {
                                                    await programManager.joinStandardProgram(programName: standardProgramDBRepresentation.name)
                                                }
                                            }
                                    }
                                    
//                                    RequestCustomProgramWidget()
                                }
                            }
                            else if programPageType == .pastPrograms {
                                PastProgramsView(programManager: self.programManager, viewPastProgram: { programUnformatted in
                                    programS3Representation = programUnformatted
                                    navigateToProgramInsightsView = true
                                })
                            }
                            
                            Spacer()
                        }
                        .background(
                            Rectangle()
                                .fill(.white)
                        )
                        .edgesIgnoringSafeArea(.bottom)
                    } else {
                        VStack (spacing: 3) {
                            HStack {
                                VStack (alignment: .leading, spacing: 4){
                                    HStack {
                                        Text("My Program")
                                            .font(.custom("Sailec Medium", size: 30))
                                        
                                        Image("Trophy")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 20)
                                    }
                                    Text(ProgramManager.shared.program?.programName ?? "Program")
                                        .font(.custom("Sailec Regular Italic", size: 12))
                                }
                                
                                Spacer()
                                
                                Text("Week \(DateUtility.determineWeekNumber(startDateString: ProgramManager.shared.program?.startDate ?? "Getting Week Number") ?? 1)")
                                    .bold()
                            }
                            .padding(.horizontal)
                            .padding(.bottom)
                            
                            ScrollView(.vertical) {
                                VStack (spacing: 0) {
                                    if let todaysProgram = programManager.program?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                                        
                                        HStack {
                                            Text("Today's Required Equipment")
                                                .font(.headline)
                                                .bold()
                                            
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 5)
                                         
                                        ScrollView(.horizontal) {
                                            HStack {
                                                ForEach(todaysProgram.requiredEquipment(), id: \.self) { equipment in
                                                    
                                                    VStack {
                                                        Image(equipment)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 50)
                                                        
                                                        Text(equipment)
                                                            .lineLimit(1)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                        .padding(.bottom, 3)
                                        
                                    }
                                    
                                    UpNextProgramExerciseWidget(programManager: programManager, navigateToWorkoutView: $navigateToWorkoutView)
                                        .padding(.top)
                                       
                       
                                    TodaysScheduleWidget(programManager: programManager)
                                        .padding(.bottom)

                                    GeometryReader { geometry in
                                        let totalWidth = geometry.size.width
                                        let padding: CGFloat = 10
                                        let squareWidth = (totalWidth - padding) / 2
                                        
                                        HStack(spacing: padding) {
                                            Button(action: {
                                                navigateToMetricsView = true
                                            }) {
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Program Stats")
                                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                                        .foregroundColor(.primary)
                                                    
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 8) {
                                                            Text("Your")
                                                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                                                .foregroundColor(.primary)
                                                            Text("Metrics")
                                                                .font(.system(size: 22, weight: .medium, design: .rounded))
                                                                .foregroundColor(.primary)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        Image(systemName: "chart.pie.fill")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 60, height: 60)
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                                .padding()
                                                .frame(width: squareWidth, height: squareWidth)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 24)
                                                        .fill(Color(.systemBackground))
                                                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 24)
                                                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            
                                            Button(action: {
                                                showConfirmationWidget = true
                                            }) {
                                                VStack(alignment: .leading, spacing: 16) {
                                                    Text("Leave Program")
                                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                                        .foregroundColor(.primary)
                                                    
                                                    HStack {
                                                        
                                                        Spacer()
                                                        
                                                        Image("Exit")
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 60, height: 60)
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                                .padding()
                                                .frame(width: squareWidth, height: squareWidth)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 24)
                                                        .fill(Color(.systemBackground))
                                                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 24)
                                                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                                )
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    .frame(height: (UIScreen.main.bounds.width - 10) / 2)
                                    .padding(.horizontal)
                                    
                                    
                                    HStack {
                                        Text("Achievements")
                                            .font(.headline)
                                            .bold()
                                        
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
            .navigationDestination(isPresented: $navigateToProgramInsightsView, destination: {
                PastProgramInsightView(programS3Representation: programS3Representation)
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

