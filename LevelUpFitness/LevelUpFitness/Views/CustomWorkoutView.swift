//
//  CustomWorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/15/24.
//

import SwiftUI

struct CustomWorkoutView: View {
    @State var workout: CustomWorkout?
    @State var currentExerciseIndex = 0
        
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if let workout = workout {
            ZStack {
                VStack {
                    ZStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                            }, label: {
                                Text("Finish")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "0077FF")]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            })
                        }
                        .padding(.horizontal)

                        Text("Exercise")
                            .font(.custom("Sailec Bold", size: 20))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Text(workout.name)
                            .font(.system(size: 20, weight: .medium, design: .default))

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    CustomWorkoutExerciseDataSetWidget(exerciseData: ExerciseData(sets: []), isWeight: workout.exercises[currentExerciseIndex].isWeight) {
                        if currentExerciseIndex + 1 < workout.exercises.count {
                            currentExerciseIndex += 1
                        }
                        else {
                            dismiss()
                        }
                    }
                    
                    Spacer()
                }
            }
        } else {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    CustomWorkoutView(workout: CustomWorkout(name: "", image: nil, exercises: []))
}
