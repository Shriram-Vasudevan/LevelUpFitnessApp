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
                Color.white
                
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
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                VStack (alignment: .center, spacing: 0) {
                    ZStack {
                        HStack {
                            Button(action: {
                                dismiss()
                            }, label: {
                                Image(systemName: "x.square.fill")
                                    .resizable()
                                    .foregroundColor(.black)
                                    .frame(width: 25, height: 25)
                            })
                            
                            Spacer()
                        }
                        
                        Text(workoutManager.currentExercises[workoutManager.currentExerciseIndex].name)
                            .font(.custom("EtruscoNowCondensed Bold", size: 50))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, -7)
                            .padding(.top, -10)
                            .lineLimit(1)
                    }
                    
                    Text("Reps per Set: \(workoutManager.currentExercises[workoutManager.currentExerciseIndex].reps)")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.bottom)
                    
                    Text("Set \(workoutManager.currentSetIndex + 1) / \(workoutManager.currentExerciseData.sets.count)")
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                }
                .padding([.horizontal, .bottom])
                
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
    }
}


struct WorkoutHeader: View {
    @ObservedObject var storageManager: StorageManager
    
    var dismiss: DismissAction
    var saveAction: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Image("GuyAtTheGym")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipped()
                    .cornerRadius(5)
                    
                VStack (alignment: .leading) {
                    Text(storageManager.program?.programName ?? "Today's Workout")
                        .font(.custom("EtruscoNowCondensed Bold", size: 20))
                        .lineLimit(1)
                    
                    Text("Push Yourself Today!")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .frame(height: 60)
                
                Spacer()
            }
        }
        .padding(.bottom, 10)
    }
}


#Preview {
    WorkoutView(storageManager: StorageManager())
}

