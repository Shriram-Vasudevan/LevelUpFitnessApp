//
//  GymSessionView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/22/24.
//

import SwiftUI


struct GymSessionsView: View {
    @ObservedObject var gymManager = GymManager.shared
    
    @State private var showEndSessionConfirmation = false
    @State private var navigateToExerciseView = false
    @State private var navigateToPastSessionDetailView = false
    @State private var navigateToAddExerciseView = false
    @State private var selectedExerciseRecord: ExerciseRecord?
    @State private var selectedPastSession: GymSession?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    headerView
                    
                    if gymManager.currentSession == nil {
                        startNewSessionView
                    } else if let currentSession = gymManager.currentSession {
                        activeGymSessionView(currentSession)
                    }
                    
                    pastSessionsView
                    
                    if gymManager.gymSessions.count > 0 {
                        gymStatsView
                    }
                }
                .padding(.horizontal)
            }

            if showEndSessionConfirmation {
                EndSessionConfirmationView(isOpen: $showEndSessionConfirmation, confirmed: {
                    gymManager.endGymSession()
                    print("Session Ended")
                })
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showEndSessionConfirmation)
            }
        }
        .navigationDestination(isPresented: $navigateToExerciseView) {
            if let exerciseRecord = selectedExerciseRecord {
                GymSessionExerciseView(exerciseRecord: exerciseRecord)
            }
        }
        .navigationDestination(isPresented: $navigateToPastSessionDetailView) {
            if let pastSession = selectedPastSession {
                PastGymSessionDetailView(session: pastSession)
            }
        }
        .navigationDestination(isPresented: $navigateToAddExerciseView) {
            AddExerciseView(onAddExercise: { exerciseRecord in
                gymManager.currentSession?.addIndividualExercise(exerciseRecord: exerciseRecord)
            })
        }
        .navigationBarBackButtonHidden()
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gym Sessions")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: "333333"))
            
            Text("Track your progress, crush your goals")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }

    private var startNewSessionView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "figure.walk")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(hex: "40C4FC"))
                
                Spacer()
                
                Text("Ready to crush it?")
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(Color(hex: "333333"))
            }
            
            Text("Start a new gym session to track your workout and progress.")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Color(hex: "666666"))
                .multilineTextAlignment(.leading)
            
            Button(action: {
                gymManager.startGymSession()
            }) {
                HStack {
                    Spacer()
                    Text("Start New Session")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Color.white)
                    Spacer()
                }
                .padding()
                .background(Color(hex: "40C4FC"))
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }


    private func activeGymSessionView(_ currentSession: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Session")
                        .font(.system(size: 20, weight: .medium, design: .default))
                        .foregroundColor(Color(hex: "333333"))
                    
                    Text(gymManager.elapsedTime)
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
                
                Spacer()
                
                Button(action: {
                    showEndSessionConfirmation = true
                }) {
                    Text("End")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color(hex: "FF3B30"))
                }
            }
            
            exercisesListView(currentSession)
            
            Button(action: {
                navigateToAddExerciseView = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Custom Exercise")
                }
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .leading, endPoint: .trailing)
                )
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }


    private func exercisesListView(_ currentSession: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completed Exercises")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "333333"))
            
            ForEach(currentSession.programExercises.flatMap { $0.value } + currentSession.individualExercises) { exerciseRecord in
                Button(action: {
                    selectedExerciseRecord = exerciseRecord
                    navigateToExerciseView = true
                }) {
                    exerciseWidget(for: exerciseRecord)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func exerciseWidget(for exerciseRecord: ExerciseRecord) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "figure.walk")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(25)

            VStack(alignment: .leading, spacing: 4) {
                switch exerciseRecord.exerciseInfo {
                    case .programExercise(let programExercise):
                        Text(programExercise.name)
                            .font(.system(size: 16, weight: .light))
                    case .libraryExercise(let libraryExercise):
                        Text(libraryExercise.name)
                            .font(.system(size: 16, weight: .light))
                }

                if let sets = exerciseRecord.exerciseData.sets.first {
                    Text("\(sets.reps) reps • \(sets.weight) lbs")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(hex: "666666"))
                }
            }

            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "CCCCCC"))
        }
        .padding()
        .background(Color(hex: "F9F9F9"))
        .cornerRadius(15)
    }

    private var pastSessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Past Sessions")
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(Color(hex: "333333"))
                
                Spacer()
            }
            
            if gymManager.gymSessions.isEmpty {
                Text("No past sessions found.")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(Color(hex: "666666"))
            } else {
                ForEach(gymManager.loadAllGymSessions()) { session in
                    Button(action: {
                        selectedPastSession = session
                        navigateToPastSessionDetailView = true
                    }) {
                        pastSessionWidget(for: session)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(24)
        .background(Color(hex: "F5F5F5"))
    }
    
    private var gymStatsView: some View {
        VStack (spacing: 16) {
            HStack {
                Text("Your Trends")
                    .font(.system(size: 20, weight: .medium, design: .default))
                    .foregroundColor(Color(hex: "333333"))
                
                Spacer()
            }
            
            GymSessionsStatsView()
        }
    }

    private func pastSessionWidget(for session: GymSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(session.startTime, style: .date)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "333333"))
                
                Text("\(session.programExercises.flatMap { $0.value }.count + session.individualExercises.count) exercises • \((session.duration ?? 0.0) / 60, specifier: "%.1f") mins")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(Color(hex: "666666"))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(hex: "CCCCCC"))
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }

}

struct GymSessionExerciseView: View {
    let exerciseRecord: ExerciseRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exerciseTitle)
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 20)
            
            ForEach(Array(exerciseRecord.exerciseData.sets.enumerated()), id: \.offset) { index, set in
                setDetailView(for: set, setIndex: index + 1)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .navigationTitle(exerciseTitle)
    }
    
    private var exerciseTitle: String {
        switch exerciseRecord.exerciseInfo {
        case .programExercise(let programExercise):
            return programExercise.name
        case .libraryExercise(let libraryExercise):
            return libraryExercise.name
        }
    }
    
    private func setDetailView(for set: ExerciseDataSet, setIndex: Int) -> some View {
        HStack {
            Text("Set \(setIndex)")
                .font(.system(size: 18, weight: .light))
            
            Spacer()
            
            Text("\(set.reps) reps • \(set.weight) lbs")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}


struct EndSessionConfirmationView: View {
    @Binding var isOpen: Bool
    var confirmed: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isOpen = false
                    }
                }
            
            VStack(spacing: 24) {
                Text("End Gym Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
                
                Text("Are you sure you want to end your gym session?")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "666666"))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            isOpen = false
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "F5F5F5"))
                    }
                    
                    Button(action: {
                        withAnimation {
                            confirmed()
                            isOpen = false
                        }
                    }) {
                        Text("End Session")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "40C4FC"))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .padding()
        }
    }
}

struct PastGymSessionDetailView: View {
    let session: GymSession
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView (.vertical) {
                VStack(spacing: 16) {
                    HStack {
                        backButton
                        
                        Spacer()
                    }
                    
                    sessionDetailsCard
                    exercisesListView
                    
                }
                .padding(.horizontal)
                
                VStack (spacing: 6) {
                    HStack {
                        Text("Session Stats")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    
                    GymSessionStatsView(session: session)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session Details")
                .font(.system(size: 24, weight: .medium, design: .default))
                .foregroundColor(Color(hex: "333333"))
            
            Text("Review your past workout")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var sessionDetailsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Past Gym Session")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "333333"))
                    
                    Text(session.startTime, style: .date)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(Color(hex: "666666"))
                }
                
                Spacer()
                
                Image(systemName: "clock")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            Divider()
            
            HStack {
                timeInfoView(title: "Start", time: session.startTime)
                Spacer()
                timeInfoView(title: "End", time: session.endTime ?? Date())
            }
            
            HStack {
                infoView(title: "Duration", value: String(format: "%.1f mins", (session.duration ?? 0.0) / 60))
                Spacer()
                infoView(title: "Exercises", value: "\(session.programExercises.flatMap { $0.value }.count + session.individualExercises.count)")
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
    
    private func timeInfoView(title: String, time: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(hex: "666666"))
            Text(time, style: .time)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "333333"))
        }
    }
    
    private func infoView(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(hex: "666666"))
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "333333"))
        }
    }
    
    private var exercisesListView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Completed Exercises")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            ForEach(session.programExercises.flatMap { $0.value } + session.individualExercises) { exerciseRecord in
                exerciseWidget(for: exerciseRecord)
            }
        }
//        .background(Color(hex: "F5F5F5"))
    }
    
    private func exerciseWidget(for exerciseRecord: ExerciseRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    switch exerciseRecord.exerciseInfo {
                        case .programExercise(let programExercise):
                            Text(programExercise.name)
                                .font(.system(size: 18, weight: .medium))
                        case .libraryExercise(let libraryExercise):
                            Text(libraryExercise.name)
                                .font(.system(size: 18, weight: .medium))
                    }

                    Text("\(exerciseRecord.exerciseData.sets.count) sets")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color(hex: "666666"))
                }

                Spacer()
            }
            
            ForEach(Array(exerciseRecord.exerciseData.sets.enumerated()), id: \.offset) { index, set in
                HStack {
                    Text("Set \(index + 1)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color(hex: "666666"))
                    Spacer()
                    Text("\(set.reps) reps • \(set.weight) lbs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "333333"))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "40C4FC"))
                .frame(width: 40, height: 40)
        }
    }
}



struct AddExerciseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var exerciseName: String = ""
    @State private var sets: [ExerciseDataSet] = [ExerciseDataSet(weight: 0, reps: 0, time: 0, rest: 0)]
    
    var onAddExercise: (ExerciseRecord) -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
                Spacer()
            }
            .padding()

            Text("Add Custom Exercise")
                .font(.system(size: 24, weight: .bold))
                .padding(.top, 8)

            TextField("Exercise Name", text: $exerciseName)
                .font(.system(size: 18, weight: .medium))
                .padding()
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(8)
                .padding(.horizontal)

            ScrollView {
                ForEach(sets.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set \(index + 1)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)

                        inputFieldsView(for: index)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal)
                    Divider()
                }
            }

            Button(action: {
                sets.append(ExerciseDataSet(weight: 0, reps: 0, time: 0, rest: 0))
            }) {
                Text("Add Set")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(8)
            }
            .padding()

            Spacer()

            Button(action: {
                let exerciseRecord = ExerciseRecord(
                    exerciseInfo: .libraryExercise(Progression(name: exerciseName, description: "", level: 0, cdnURL: "", exerciseType: "", isWeight: false)),
                    exerciseData: ExerciseData(sets: sets)
                )
                onAddExercise(exerciseRecord)
                dismiss()
            }) {
                Text("Add Exercise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden()
    }

    private func inputFieldsView(for index: Int) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                inputField(title: "Weight", value: $sets[index].weight, unit: "lbs")
                inputField(title: "Reps", value: $sets[index].reps, unit: "reps")
            }

            HStack(spacing: 16) {
                inputField(title: "Time", value: $sets[index].time, unit: "seconds")
                inputField(title: "Rest", value: $sets[index].rest, unit: "seconds")
            }
        }
    }

    private func inputField(title: String, value: Binding<Int>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.secondary)
            HStack {
                TextField("0", value: value, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .medium))
                Text(unit)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }

    private func inputField(title: String, value: Binding<Double>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.secondary)
            HStack {
                TextField("0", value: value, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .font(.system(size: 18, weight: .medium))
                Text(unit)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

