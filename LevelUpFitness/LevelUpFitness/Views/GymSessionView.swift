//
//  GymSessionView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/22/24.
//

import SwiftUI

import SwiftUI

struct GymSessionsView: View {
    @ObservedObject var gymManager = GymManager.shared
    
    @State private var showEndSessionConfirmation = false
    @State private var navigateToExerciseView = false
    @State private var navigateToPastSessionDetailView = false
    @State private var selectedExerciseRecord: ExerciseRecord?
    @State private var selectedPastSession: GymSession?

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        headerView
                        
                        if gymManager.currentSession == nil {
                            startNewSessionView
                        } else {
                            if let currentSession = gymManager.currentSession {
                                activeGymSessionView(currentSession)
                            }
                        }
                    }
                    
                    pastSessionsView
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
        .background(Color.white.ignoresSafeArea())
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
        .navigationBarBackButtonHidden()
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Gym Sessions")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
        }
        .padding(.top, 15)
    }

    private var startNewSessionView: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("No Active Session")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.black)
            
            Text("You don't have any ongoing gym session. Start one to begin tracking your workout.")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button(action: {
                gymManager.startGymSession()
            }) {
                Text("Start New Session")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }

    private func activeGymSessionView(_ currentSession: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Gym Session")
                .font(.system(size: 20, weight: .medium))
            
            HStack {
                Text("Elapsed Time: \(gymManager.elapsedTime)")
                    .font(.system(size: 16, weight: .light))
                
                Spacer()
                
                Button(action: {
                    showEndSessionConfirmation = true
                }) {
                    Text("End Session")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "40C4FC"))
                        .cornerRadius(8)
                }
            }
            
            Divider()
            
            Text("Completed Exercises")
                .font(.system(size: 18, weight: .light))
            
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
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }

    private func exerciseWidget(for exerciseRecord: ExerciseRecord) -> some View {
        HStack {
            Image(systemName: "figure.walk")
                .foregroundColor(Color(hex: "40C4FC"))
                .frame(width: 30, height: 30)

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
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(.gray)
                }
            }

            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }

    private var pastSessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Past Gym Sessions")
                    .font(.system(size: 20, weight: .medium))
                
                Spacer()
            }
            
            if gymManager.gymSessions.isEmpty {
                HStack {
                    Text("No past sessions found.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
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
    }

    private func pastSessionWidget(for session: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.startTime, style: .date)
                    .font(.system(size: 16, weight: .light))
                
                Spacer()
                
                Text("\((session.duration ?? 0.0) / 60, specifier: "%.1f") mins")
                    .font(.system(size: 16, weight: .light))
            }
            
            Text("\(session.programExercises.flatMap { $0.value }.count + session.individualExercises.count) exercises completed")
                .font(.system(size: 14, weight: .ultraLight))
                .foregroundColor(.gray)
            
            Divider()
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }
}

struct GymSessionExerciseView: View {
    let exerciseRecord: ExerciseRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exerciseTitle)
                .font(.system(size: 20, weight: .medium))
            
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
    
    @State private var offsetValue: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isOpen = false
                        }
                    }
            }
            
            VStack(spacing: 20) {
                Text("End Gym Session")
                    .font(.system(size: 20, weight: .medium))
                
                Text("Are you sure you want to end your gym session?")
                    .font(.system(size: 16, weight: .light))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            isOpen = false
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        withAnimation {
                            confirmed()
                            isOpen = false
                        }
                    }) {
                        Text("End Session")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .padding()
            .offset(y: offsetValue)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offsetValue = 0
                }
            }
            .onDisappear {
                withAnimation {
                    offsetValue = UIScreen.main.bounds.height
                }
            }
        }
    }
}



struct PastGymSessionDetailView: View {
    let session: GymSession
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "40C4FC"))
                    }
                    Spacer()
                }
                
                Text("Session Details")
                    .font(.system(size: 18, weight: .semibold))
            }
            
            Text("Past Gym Session")
                .font(.system(size: 24, weight: .medium))
            
            HStack {
                Text("Start: \(session.startTime, style: .time)")
                    .font(.system(size: 16, weight: .light))
                Spacer()
                if let endTime = session.endTime {
                    Text("End: \(endTime, style: .time)")
                        .font(.system(size: 16, weight: .light))
                }
            }
            
            Divider()

            Text("Completed Exercises")
                .font(.system(size: 18, weight: .light))
            
            ForEach(session.programExercises.flatMap { $0.value } + session.individualExercises) { exerciseRecord in
                exerciseDetailWidget(for: exerciseRecord)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .navigationBarBackButtonHidden()
    }
    
    private func exerciseDetailWidget(for exerciseRecord: ExerciseRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            switch exerciseRecord.exerciseInfo {
            case .programExercise(let programExercise):
                Text(programExercise.name)
                    .font(.system(size: 16, weight: .light))
            case .libraryExercise(let libraryExercise):
                Text(libraryExercise.name)
                    .font(.system(size: 16, weight: .light))
            }
            
            ForEach(Array(exerciseRecord.exerciseData.sets.enumerated()), id: \.offset) { index, set in
                HStack {
                    Text("Set \(index + 1):")
                    Spacer()
                    Text("\(set.reps) reps • \(set.weight) lbs")
                        .font(.system(size: 14, weight: .ultraLight))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }
}


