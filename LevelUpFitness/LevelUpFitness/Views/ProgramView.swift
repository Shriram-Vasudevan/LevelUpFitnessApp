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
    @State var showConfirmationWidget: Bool = false
    @State var programPageType: ProgramPageTypes = .newProgram
    @State var navigateToProgramInsightsView: Bool = false
    @State var programS3Representation: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(ProgramManager.shared.program?.programName ?? "My Program")
                                    .font(.system(size: 22, weight: .bold, design: .default))
                                Text("Week \(DateUtility.determineWeekNumber(startDateString: ProgramManager.shared.program?.startDate ?? "") ?? 1)")
                                    .font(.system(size: 12, weight: .ultraLight, design: .default))
                                    .foregroundColor(Color(hex: "F5F5F5"))
                            }
                            Spacer()
                        }
                        
                        if programManager.program == nil && !programManager.retrievingProgram {
                            VStack(spacing: 24) {
                                segmentedControl
                                
                                if programPageType == .newProgram {
                                    newProgramView
                                } else {
                                    pastProgramsView
                                }
                            }
                        } else {
                            if let todaysProgram = programManager.program?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Today's Required Equipment")
                                        .font(.system(size: 20, weight: .medium, design: .default))
                                        .foregroundColor(.black)
                                    
                                    if todaysProgram.requiredEquipment().isEmpty {
                                        Text("No equipment required for today's workout")
                                            .font(.system(size: 16, weight: .regular, design: .default))
                                            .foregroundColor(.gray)
                                    } else {
                                        ScrollView(.horizontal) {
                                            HStack {
                                                ForEach(todaysProgram.requiredEquipment(), id: \.self) { equipment in
                                                    EquipmentItemView(equipment: equipment)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom)
                                
                                activeProgramView
                            }
                        }
                    }
                    .padding()
                }
                
                if showConfirmationWidget {
                    ConfirmLeaveProgramWidget(isOpen: $showConfirmationWidget, confirmed: {
                        Task {
                            await programManager.leaveProgram()
                        }
                    })
                }
                
            }
        }
        .fullScreenCover(isPresented: $navigateToWorkoutView) {
            WorkoutView(programManager: programManager, xpManager: xpManager)
        }
        .fullScreenCover(isPresented: $navigateToMetricsView) {
            if let program = programManager.program {
                ProgramStatisticsView(program: program)
            }
        }
        .navigationDestination(isPresented: $navigateToProgramInsightsView) {
            PastProgramInsightView(programS3Representation: programS3Representation)
        }
    }

    private var segmentedControl: some View {
        HStack {
            Button(action: { programPageType = .newProgram }) {
                Text("Join Program")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.black)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(programPageType == .newProgram ? Color(hex: "40C4FC").opacity(0.1) : Color.clear)
            }
            
            Button(action: { programPageType = .pastPrograms }) {
                Text("Past Programs")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.black)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(programPageType == .pastPrograms ? Color(hex: "40C4FC").opacity(0.1) : Color.clear)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
    
    private var newProgramView: some View {
        VStack(spacing: 16) {
            ForEach(programManager.standardProgramDBRepresentations ?? [], id: \.id) { program in
                JoinProgramWidget(standardProgramDBRepresentation: program)
                    .onTapGesture {
                        Task {
                            await programManager.joinStandardProgram(programName: program.name)
                        }
                    }
            }
        }
    }
    
    private var pastProgramsView: some View {
        PastProgramsView(programManager: self.programManager, viewPastProgram: { programUnformatted in
            programS3Representation = programUnformatted
            navigateToProgramInsightsView = true
        })
    }
    


    private var activeProgramView: some View {
        VStack(spacing: 16) {
            UpNextProgramExerciseWidget(programManager: programManager, navigateToWorkoutView: $navigateToWorkoutView)
            
            TodaysScheduleWidget(programManager: programManager)
            
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let padding: CGFloat = 10
                let squareWidth = (totalWidth - padding) / 2
                
                HStack(spacing: padding) {
                    Button(action: {
                        navigateToMetricsView = true
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Program Stats")
                                .font(.system(size: 18, weight: .light, design: .default))
                            
                            HStack {
                                Image(systemName: "chart.pie.fill")
                                    .foregroundColor(Color(hex: "40C4FC"))
                                Spacer()
                            }
                        }
                        .padding()
                        .frame(width: squareWidth, height: squareWidth / 2)
                        .background(Color(hex: "F5F5F5"))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showConfirmationWidget = true
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Leave Program")
                                .font(.system(size: 18, weight: .light, design: .default))
                            
                            HStack {
                                Spacer()
                                Image("Exit")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 24)
                            }
                        }
                        .padding()
                        .frame(width: squareWidth, height: squareWidth / 2)
                        .background(Color(hex: "F5F5F5"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(height: (UIScreen.main.bounds.width - 10) / 2)
            
            achievementsView
        }
    }
    
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 20, weight: .light, design: .default))
            
            ForEach(badgeManager.badges.sorted(by: { $0.badgeCriteria.threshold < $1.badgeCriteria.threshold }), id: \.id) { badge in
                if let userBadgeInfo = badgeManager.userBadgeInfo {
                    AchievementWidget(userBadgeInfo: userBadgeInfo, badge: badge)
                        .opacity(userBadgeInfo.badgesEarned.contains(badge.id) ? 1 : 0.5)
                }
            }
        }
    }
}

struct EquipmentItemView: View {
    let equipment: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(equipment)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(Color(hex: "40C4FC"))
            
            Text(equipment)
                .font(.system(size: 14, weight: .regular, design: .default))
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
    }
}

struct UpNextProgramExerciseWidget: View {
    @ObservedObject var programManager: ProgramManager
    @Binding var navigateToWorkoutView: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Up Next")
                .font(.system(size: 20, weight: .medium, design: .default))
            
            if let todaysProgram = programManager.program?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }),
               let (_, nextExercise) = todaysProgram.exercises.enumerated().first(where: { !$0.element.completed }) {
                exerciseDetailsView(for: nextExercise)
            } else {
                noWorkoutView
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .onTapGesture {
            withAnimation(.spring()) {
                navigateToWorkoutView = true
            }
        }
    }
    
    private func exerciseDetailsView(for exercise: ProgramExercise) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.system(size: 18, weight: .light, design: .default))
                
                HStack(spacing: 12) {
                    detailItem(title: "Sets", value: "\(exercise.sets)")
                    detailItem(title: "Reps", value: "\(exercise.reps)")
                    detailItem(title: "RPE", value: "\(exercise.rpe)")
                    detailItem(title: "Rest", value: "\(exercise.rest)s")
                }
            }
            
            Spacer()
            
            exerciseIcon(for: exercise)
        }
    }
    
    private func exerciseIcon(for exercise: ProgramExercise) -> some View {
        Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.walk")
            .resizable()
            .scaledToFit()
            .frame(width: 30, height: 30)
            .foregroundColor(Color(hex: "40C4FC"))
    }
    
    private func detailItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 12, weight: .ultraLight, design: .default))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 14, weight: .light, design: .default))
        }
    }
    
    private var noWorkoutView: some View {
        Text("No workout for today")
            .font(.system(size: 16, weight: .light, design: .default))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
}

struct TodaysScheduleWidget: View {
    @ObservedObject var programManager: ProgramManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Schedule")
                .font(.system(size: 20, weight: .medium, design: .default))
            
            if let todaysProgram = programManager.program?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                let relevantExercises = getRelevantExercises(from: todaysProgram.exercises)
                
                ForEach(relevantExercises, id: \.name) { exercise in
                    ExerciseRow(exercise: exercise)
                }
                
                if todaysProgram.exercises.count > 3 {
                    Text("\(todaysProgram.exercises.count - relevantExercises.count) more exercise(s) in today's program")
                        .font(.system(size: 14, weight: .ultraLight, design: .default))
                        .foregroundColor(.gray)
                }
            } else {
                Text("No exercises scheduled for today")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
    
    private func getRelevantExercises(from exercises: [ProgramExercise]) -> [ProgramExercise] {
        guard !exercises.isEmpty else { return [] }
        
        if let currentIndex = exercises.firstIndex(where: { !$0.completed }) {
            let endIndex = min(currentIndex + 3, exercises.count)
            if endIndex - currentIndex < 3 {
                return Array(exercises.suffix(3))
            } else {
                return Array(exercises[currentIndex..<endIndex])
            }
        } else {
            return Array(exercises.suffix(3))
        }
    }
}


struct ExerciseRow: View {
    let exercise: ProgramExercise
    
    var body: some View {
        HStack {
            Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.walk")
                .foregroundColor(Color(hex: "40C4FC"))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .light, design: .default))
                Text("\(exercise.sets) sets • \(exercise.reps) reps • RPE \(exercise.rpe)")
                    .font(.system(size: 14, weight: .ultraLight, design: .default))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: exercise.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(exercise.completed ? Color(hex: "40C4FC") : .gray)
        }
    }
}


#Preview {
    ProgramView(programManager: ProgramManager(), badgeManager: BadgeManager(), xpManager: XPManager())
}

