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
                }
                .padding(.horizontal)
            }

            if showEndSessionConfirmation {
                EndSessionConfirmationView(isOpen: $showEndSessionConfirmation, confirmed: {
                    gymManager.endGymSession()
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Gym Sessions")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 15)

            Divider()
        }
    }

    private var startNewSessionView: some View {
        VStack(alignment: .center, spacing: 24) {
            Text("No Active Session")
                .font(.system(size: 22, weight: .medium))

            Text("You don't have any ongoing gym session. Start one to begin tracking your workout.")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(action: {
                gymManager.startGymSession()
            }) {
                Text("Start New Session")
                    .font(.system(size: 16, weight: .bold))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3DA5F5")]), startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(16)
    }

    private func activeGymSessionView(_ currentSession: GymSession) -> some View {
        VStack(alignment: .center, spacing: 16) {
            VStack {
                Text("Elapsed Time")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(.gray)

                Text(gymManager.elapsedTime)
                    .font(.system(size: 64, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 30)
                    .padding(.horizontal, 40)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3DA5F5")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .cornerRadius(24)
                    .shadow(radius: 10)
            }
            .padding(.top, 20)

            Button(action: {
                showEndSessionConfirmation = true
            }) {
                Text("End Session")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .shadow(radius: 5)
            }
            .padding(.top, 20)

            Divider()

            Text("Completed Exercises")
                .font(.system(size: 18, weight: .medium))
                .padding(.top, 12)

            ForEach(currentSession.programExercises.flatMap { $0.value } + currentSession.individualExercises) { exerciseRecord in
                Button(action: {
                    selectedExerciseRecord = exerciseRecord
                    navigateToExerciseView = true
                }) {
                    exerciseWidget(for: exerciseRecord)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Button(action: {
                navigateToAddExerciseView = true
            }) {
                Text("Add Custom Exercise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3DA5F5")]), startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(12)
                    .shadow(radius: 5)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(16)
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
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    private var pastSessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Past Gym Sessions")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)

            if gymManager.gymSessions.isEmpty {
                Text("No past sessions found.")
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.gray)
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
        .padding(.vertical, 24)
    }

    private func pastSessionWidget(for session: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.startTime, style: .date)
                    .font(.system(size: 16, weight: .medium))
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
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

// Redesigned GymSessionExerciseView
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

// Redesigned EndSessionConfirmationView
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

// Redesigned AddExerciseView
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
            .padding(.bottom, 30)
        }
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

// Redesigned PastGymSessionDetailView
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
            .padding(.top)

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
