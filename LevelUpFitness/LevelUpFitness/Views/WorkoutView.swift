//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var workoutManager: WorkoutManager
    @ObservedObject private var storageManager: StorageManager
    
    @Environment(\.dismiss) var dismiss
    
    @State private var setCompleted: () -> Void = {}
    @State private var lastSetCompleted: () -> Void = {}
    
    init(storageManager: StorageManager) {
        _workoutManager = StateObject(wrappedValue: WorkoutManager(storageManager: storageManager))
        self.storageManager = storageManager
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 248/255.0, green: 4/255.0, blue: 76/255.0)
                    .edgesIgnoringSafeArea(.all)
                
                if !workoutManager.hasExercisesForToday() {
                    Text("No exercises for today")
                        .foregroundColor(.white)
                } else if workoutManager.isWorkoutComplete() {
                    Text("Workout completed!")
                        .foregroundColor(.white)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                } else {
                    WorkoutContent(workoutManager: workoutManager, storageManager: storageManager, dismiss: dismiss, setCompleted: $setCompleted, lastSetCompleted: $lastSetCompleted)
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                workoutManager.initializeExerciseData() 
                setupCallbacks()
            }
        }
    }
    
    private func setupCallbacks() {
        setCompleted = {
            print("Moving to next set")
            workoutManager.moveToNextSet()
        }
        
        lastSetCompleted =  {
            print("Moving to next exercise")
            workoutManager.moveToNextExercise()
        }
    }
}

struct WorkoutContent: View {
    @ObservedObject var workoutManager: WorkoutManager
    @ObservedObject var storageManager: StorageManager
    var dismiss: DismissAction
    @Binding var setCompleted: () -> Void
    @Binding var lastSetCompleted: () -> Void
    
    var body: some View {
        VStack (spacing: 0) {
            WorkoutHeader(storageManager: storageManager, dismiss: dismiss)
            
            ExerciseDataSetWidget(
                model: $workoutManager.currentExerciseData.sets[workoutManager.currentSetIndex],
                isLastSet: workoutManager.onLastSet,
                setIndex: workoutManager.currentSetIndex,
                setCompleted: $setCompleted,
                lastSetCompleted: $lastSetCompleted,
                exerciseName: workoutManager.currentExercises[workoutManager.currentExerciseIndex].name, exerciseReps: workoutManager.currentExercises[workoutManager.currentExerciseIndex].reps, numberOfSets: workoutManager.currentExerciseData.sets.count, exitWorkout: {
                    dismiss()
                }
            )
            .id("\(workoutManager.currentExerciseIndex)-\(workoutManager.currentSetIndex)")
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white)
            )
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}


struct WorkoutHeader: View {
    @ObservedObject var storageManager: StorageManager
    
    @State var timeText: String = "00:00"
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    var dismiss: DismissAction

    var body: some View {
        ZStack {
            HStack {
                Text("Workout Time")
                    .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(timeText)
                    .font(.custom("Sailec Bold", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, 5)
            }
            .padding(.horizontal)
       }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func startTimer() {
            elapsedTime = 0.0
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                elapsedTime += 0.1
                let minutes = Int(elapsedTime) / 60
                let seconds = Int(elapsedTime) % 60
                timeText = String(format: "%02d:%02d", minutes, seconds)
            })
        }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


#Preview {
    WorkoutView(storageManager: StorageManager())
}

