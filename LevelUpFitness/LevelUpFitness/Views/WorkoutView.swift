//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var storageManager: StorageManager
    
    @State var currentExercises: [Exercise] = []
    @State var currentExerciseIndex: Int = 0

    var programWorkoutManager = ProgramWorkoutManager()
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            if currentExercises.count > 0 {
                VStack {
                    
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        })
                        
                        Text("Back")
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        VStack (alignment: .leading, spacing: 0) {
                            Text(currentExercises[currentExerciseIndex].name)
                                .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                .padding(.bottom, -7)
                            
                            HStack {
                                Text("Reps: \(currentExercises[currentExerciseIndex].reps)")
                                Text("Sets: \(currentExercises[currentExerciseIndex].sets)")
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                currentExercises[currentExerciseIndex].completed = true
                                currentExerciseIndex += 1
                            }
                        }, label: {
                            Text("Complete")
                                .font(.footnote)
                                .foregroundColor(.black)
                                .bold()
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(.green)
                                )
                        })
                    }
                    .padding([.horizontal, .bottom])

                    
                    Image("GuyAtTheGym")
                        .resizable()
                        .frame(height:  200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Visual Demonstration")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            else if currentExercises.count - 1 == currentExerciseIndex {
                
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            if let todaysProgram = storageManager.program?.program.first(where: { $0.day == programWorkoutManager.getCurrentWeekday() }) {
                self.currentExercises = todaysProgram.exercises
                
                print(currentExercises)
                
                if let (index, exercise) = todaysProgram.exercises.enumerated().first(where: { $0.element.completed == true }) {
                    self.currentExerciseIndex = index
                    
                }
            }
            else {
                print("none")
            }
        }
    }
}

#Preview {
    WorkoutView(storageManager: StorageManager())
}
