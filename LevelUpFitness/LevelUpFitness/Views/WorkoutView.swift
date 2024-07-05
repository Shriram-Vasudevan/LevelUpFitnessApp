//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    @State private var setCompleted: () -> Void = {}
    @State private var lastSetCompleted: () -> Void = {}
    
    init(storageManager: StorageManager) {
        _workoutManager = StateObject(wrappedValue: WorkoutManager(storageManager: storageManager))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue
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
                    WorkoutContent(workoutManager: workoutManager, dismiss: dismiss, setCompleted: $setCompleted, lastSetCompleted: $lastSetCompleted)
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
    var dismiss: DismissAction
    @Binding var setCompleted: () -> Void
    @Binding var lastSetCompleted: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            WorkoutHeader(dismiss: dismiss, saveAction: {
                Task {
                    await workoutManager.storageManager.uploadNewProgramStatus(completionHandler: {
                        dismiss()
                    })
                }
            })

            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ExerciseVideoWidget(exercise: workoutManager.currentExercises[workoutManager.currentExerciseIndex])
                    
                    ExerciseDataSetWidget(
                        model: $workoutManager.currentExerciseData.sets[workoutManager.currentSetIndex],
                        isLastSet: workoutManager.onLastSet,
                        setIndex: workoutManager.currentSetIndex,
                        setCompleted: $setCompleted,
                        lastSetCompleted: $lastSetCompleted
                    )
                    .id(workoutManager.currentSetIndex) 
                    
                    Spacer()
                }
            }
            .background(Rectangle().fill(.white))
            .ignoresSafeArea(.all)
        }
    }
}


struct WorkoutHeader: View {
    var dismiss: DismissAction
    var saveAction: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: { 
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                }
                
                Text("Close").foregroundColor(.white)
                Spacer()
                Button(action: saveAction) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            
            Text("Workout")
                .bold()
                .foregroundColor(.white)
        }
        .padding(.bottom, 10)
    }
}

struct ExerciseVideoWidget: View {
    var exercise: Exercise
    
    var body: some View {
        VStack(spacing: 0) {
            Image("GuyAtTheGym")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .cornerRadius(10)
                .padding()
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(exercise.name)
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding([.horizontal, .bottom])
        }
    }
}

#Preview {
    WorkoutView(storageManager: StorageManager())
}

