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
            
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    
                    VStack (alignment: .center, spacing: 0) {
                        ZStack {
//                            HStack {
//                                Button(action: {
//                                    dismiss()
//                                }, label: {
//                                    Image(systemName: "x.square.fill")
//                                        .resizable()
//                                        .foregroundColor(.black)
//                                        .frame(width: 25, height: 25)
//                                })
//                                
//                                Spacer()
//                            }
//                            
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
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}


struct WorkoutHeader: View {
    @ObservedObject var storageManager: StorageManager
    
    var dismiss: DismissAction

    var body: some View {
        ZStack {
           HStack {
               Button(action: {
                   dismiss()
               }, label: {
                   Image(systemName: "xmark")
                       .foregroundColor(.white)
               })
               
               Text("Close")
                   .foregroundColor(.white)
               
               Spacer()
               
               Button(action: {
                   Task {
                       await storageManager.uploadNewProgramStatus(completionHandler: {
                           dismiss()
                       })
                   }
               }) {
                   Text("Save")
                       .fontWeight(.bold)
                       .foregroundColor(.white)
               }
               
           }
           .padding(.horizontal)
           
           HStack {
               Spacer()
               
               Text("Workout")
                   .bold()
                   .foregroundColor(.white)
               
               Spacer()
           }
           .padding(.horizontal)
       }
        .padding(.bottom, 10)
    }
}


#Preview {
    WorkoutView(storageManager: StorageManager())
}

