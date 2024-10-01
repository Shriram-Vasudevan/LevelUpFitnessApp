//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI

struct ProgramView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var badgeManager = BadgeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    
    @State var navigateToWorkoutView: Bool = false
    @State var navigateToMetricsView: Bool = false
    @State var showConfirmationWidget: Bool = false
    @State var programPageType: ProgramPageTypes = .newProgram
    @State var navigateToProgramInsightsView: Bool = false
    @State var programS3Representation: String = ""
    
    @State private var isHeaderExpanded: Bool = false
    @State private var showProgramPicker: Bool = false
    
    @State var showProgramManagerOptions: Bool = false
    
    @State var showPastPrograms: Bool = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    programHeader
                    
                    if programManager.selectedProgram == nil {
                        
                        VStack(spacing: 20) {
                            
                            if programManager.userProgramData.count > 0 {
                                userActiveProgramsTabView
                            }

                            VStack (spacing: 8) {
                                programSectionHeader("For Gym")
                                gymProgramsScrollView
                            }
                            
                            VStack (spacing: 8) {
                                programSectionHeader("For Home")
                                homeProgramsScrollView
                            }

                            Button(action: {
                                showPastPrograms.toggle()
                            }) {
                                HStack {
                                    Text(showPastPrograms ? "Show Active Programs" : "Show Past Programs")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(hex: "40C4FC"))
                                    
                                    Spacer()
                                }
                            }
                            
                            if showPastPrograms {
                                pastProgramsScrollView
                            }
                        }
                    } else {
                        programContent
                    }
                }
                .padding(.horizontal)
            }
            
            if showConfirmationWidget {
                ConfirmLeaveProgramWidget(isOpen: $showConfirmationWidget, confirmed: {
                    Task {
                        if let programID = ProgramManager.shared.selectedProgram?.programID
                        {
                            await programManager.leaveProgram(programID: programID, completion: { success in
                                
                            })
                            ProgramManager.shared.selectedProgram = nil
                        }
                    }
                })
            }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $navigateToWorkoutView) {
            WorkoutView(programManager: programManager, xpManager: xpManager)
        }
        .fullScreenCover(isPresented: $navigateToMetricsView) {
            if let selectedProgram = ProgramManager.shared.selectedProgram {
                ProgramStatisticsView(program: selectedProgram.program)
            }
        }
        .navigationDestination(isPresented: $navigateToProgramInsightsView) {
            PastProgramInsightView(programS3Representation: programS3Representation)
        }
        .sheet(isPresented: $showProgramPicker) {
            programPickerView
        }
        .onAppear {
//            if programManager.selectedProgram == nil, let firstProgram = programManager.userProgramData.first {
//                programManager.selectedProgram = firstProgram
//            }
        }
    }

    private var programHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(ProgramManager.shared.selectedProgram?.program.programName ?? "Program Manager")
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
            
            Spacer()
            
            if let weekNumber = DateUtility.determineWeekNumber(startDateString: ProgramManager.shared.selectedProgram?.program.startDate ?? "") {
                Text("Week \(weekNumber)")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
            }
            
            if ProgramManager.shared.selectedProgram?.program.programName != nil {
                Button(action: {
                    showProgramPicker = true
                }) {
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color(hex: "40C4FC"))
                        .rotationEffect(.degrees(isHeaderExpanded ? 180 : 0))
                        .frame(width: 30, height: 30)
                        .background(Color(hex: "40C4FC").opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var programPickerView: some View {
        VStack {
            Text("Select a Program")
                .font(.headline)
                .padding()

            List {
                Button(action: {
                    showProgramManagerOptions = true
                    programPageType = .newProgram
                    ProgramManager.shared.selectedProgram = nil
                    showProgramPicker = false
                }) {
                    Text("View Programs")
                        .font(.system(size: 16, weight: .medium))
                }

                ForEach(programManager.userProgramData, id: \.program.programName) { programWithID in
                    Button(action: {
                        showProgramManagerOptions = false
                        ProgramManager.shared.selectedProgram = programWithID
                        showProgramPicker = false
                    }) {
                        Text(programWithID.program.programName)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }


    private var programContent: some View {
        VStack(spacing: 8) {
            if let todaysProgram = ProgramManager.shared.selectedProgram?.program.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                requiredEquipmentView(for: todaysProgram)
                activeProgramView
            } else {
                Text("No program scheduled for today")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.gray)
            }
        }
    }

    private func requiredEquipmentView(for todaysProgram: ProgramDay) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Required Equipment")
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            if todaysProgram.requiredEquipment().isEmpty {
                HStack {
                    Text("No equipment required for today's workout")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(.gray)
                        .padding(.top, -12)
                    
                    Spacer()
                }
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
            ForEach(programManager.standardProgramDBRepresentations, id: \.id) { program in
                JoinProgramWidget(standardProgramDBRepresentation: program)
                    .onTapGesture {
                        Task {
                            await programManager.joinStandardProgram(programName: program.name, completionHandler: { programWithID in
                                showProgramManagerOptions = false
                                ProgramManager.shared.selectedProgram = programWithID
                                showProgramPicker = false
                            })
                        }
                    }
                    .opacity(programManager.userProgramData.contains(where: { Program in
                        Program.program.programName == program.name
                    }) ? 0.7 : 1)
                    .disabled(programManager.userProgramData.contains(where: { Program in
                        Program.program.programName == program.name
                    }))
            }
        }
        .onAppear {
            if programManager.standardProgramDBRepresentations.isEmpty {
                programManager.loadStandardProgramNames()
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
                                .font(.system(size: 18, weight: .light))
                            
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
        }
    }
    
    private var achievementsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 20, weight: .light))
            
            ForEach(badgeManager.badges.sorted(by: { $0.badgeCriteria.threshold < $1.badgeCriteria.threshold }), id: \.id) { badge in
                if let userBadgeInfo = badgeManager.userBadgeInfo {
                    AchievementWidget(userBadgeInfo: userBadgeInfo, badge: badge)
                        .opacity(userBadgeInfo.badgesEarned.contains(badge.id) ? 1 : 0.5)
                }
            }
        }
    }

    private var userActiveProgramsTabView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Active Programs")
                .font(.system(size: 20, weight: .bold))
            
            TabView {
                ForEach(programManager.userProgramData, id: \.program.programName) { programWithID in
                    ActiveProgramCardView(program: programWithID.program)
                        .onTapGesture {
                            showProgramManagerOptions = false
                            ProgramManager.shared.selectedProgram = programWithID
                            showProgramPicker = false
                        }
                }
            }
            .frame(height: 175)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }


    private var gymProgramsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(programManager.standardProgramDBRepresentations.filter { $0.environment.contains("Gym") }, id: \.id) { program in
                    ProgramCardView(standardProgramDBRepresentation: program)
                        .onTapGesture {
                            Task {
                                await programManager.joinStandardProgram(programName: program.name, completionHandler: { programWithID in
                                    showProgramManagerOptions = false
                                    ProgramManager.shared.selectedProgram = programWithID
                                    showProgramPicker = false
                                })
                                
//                                showProgramManagerOptions = false
//                                ProgramManager.shared.selectedProgram = programWithID
//                                showProgramPicker = false
                            }
                        }
                }
            }
        }
    }

    private var homeProgramsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(programManager.standardProgramDBRepresentations.filter { $0.environment.contains("Home") }, id: \.id) { program in
                    ProgramCardView(standardProgramDBRepresentation: program)
                        .onTapGesture {
                            Task {
                                await programManager.joinStandardProgram(programName: program.name, completionHandler: { programWithID in
                                    showProgramManagerOptions = false
                                    ProgramManager.shared.selectedProgram = programWithID
                                    showProgramPicker = false
                                })
                            }
                        }
                }
            }
        }
    }
    
    private var pastProgramsScrollView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Past Programs")
                .font(.system(size: 18, weight: .bold))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(programManager.userProgramData, id: \.program.programName) { programWithID in
                        ProgramCardView(standardProgramDBRepresentation: StandardProgramDBRepresentation(id: UUID().uuidString, name: programWithID.program.programName, environment: programWithID.program.environment))
                    }
                }
            }
        }
    }
    
    
    private func programSectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
        }
    }
    
}

struct ProgramHeader: View {
    let programName: String
    let weekNumber: Int?
    @Binding var isExpanded: Bool
    
    private let lightBlue = Color(hex: "40C4FC")
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(programName)
                .font(.system(size: 18, weight: .medium, design: .default))
                .foregroundColor(.primary)
            
            Spacer()
            
            if let weekNumber = self.weekNumber {
                Text("Week \(weekNumber)")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.secondary)
            }
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "chevron.down")
                    .foregroundColor(lightBlue)
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .frame(width: 30, height: 30)
                    .background(lightBlue.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 8)
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
            HStack {
                Text("Up Next")
                    .font(.system(size: 20, weight: .medium, design: .default))
                
                Spacer()
                
                Text("Start Now")
                    .foregroundColor(Color(hex: "40C4FC"))
                    .font(.system(size: 13, weight: .medium, design: .default))
//                    .onTapGesture {
//                        withAnimation(.spring()) {
//                            navigateToWorkoutView = true
//                        }
//                    }
            }
            
            if let todaysProgram = ProgramManager.shared.selectedProgram?.program.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }),
               let (_, nextExercise) = todaysProgram.exercises.enumerated().first(where: { !$0.element.completed }) {
                exerciseDetailsView(for: nextExercise)
                    .onTapGesture {
                        withAnimation(.spring()) {
                            navigateToWorkoutView = true
                        }
                    }
            } else {
                noWorkoutView
            }
        }
        .padding()
        .onTapGesture {
            withAnimation(.spring()) {
                navigateToWorkoutView = true
            }
        }
        .background(Color(hex: "F5F5F5"))
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
        Text("Nothing more to do!")
            .font(.system(size: 16, weight: .light, design: .default))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
}

struct TodaysScheduleWidget: View {
    @ObservedObject var programManager: ProgramManager
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Schedule")
                .font(.system(size: 20, weight: .medium, design: .default))
            
            if let todaysProgram = ProgramManager.shared.selectedProgram?.program.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                let exercises = todaysProgram.exercises
                let displayedExercises = isExpanded ? exercises : Array(exercises.prefix(3))
                
                ForEach(displayedExercises, id: \.name) { exercise in
                    ExerciseRow(exercise: exercise)
                }
                
                if exercises.count > 3 {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack {
                            Text(isExpanded ? "Show Less" : "Show All")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .background(Color(hex: "40C4FC"))
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
                }
            } else {
                Text("No exercises scheduled for today")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .animation(.easeInOut, value: isExpanded)
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

struct ActiveProgramCardView: View {
    var program: Program
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(program.programName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                
                Text(program.environment)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
                
                Spacer()
                
                HStack {
                    Text("Current Week: \(DateUtility.determineWeekNumber(startDateString: program.startDate) ?? 1)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, minHeight: 175)
    }
}


struct ProgramCardView: View {
    var standardProgramDBRepresentation: StandardProgramDBRepresentation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
            
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    path.move(to: CGPoint(x: 0, y: height * 0.4))
                    path.addCurve(to: CGPoint(x: width, y: height * 0.6),
                                  control1: CGPoint(x: width * 0.5, y: height * 0.2),
                                  control2: CGPoint(x: width * 0.8, y: height * 0.7))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .fill(Color.white.opacity(0.1))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(standardProgramDBRepresentation.name)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Text(standardProgramDBRepresentation.environment)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.2))
        }
        .frame(width: 200, height: 120)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProgramView()
}

