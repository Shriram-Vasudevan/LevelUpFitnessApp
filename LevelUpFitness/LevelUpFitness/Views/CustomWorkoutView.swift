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
    
    @State var exerciseData = ExerciseData(sets: [])
    var body: some View {
        if let workout = workout {
            ZStack {
                AppTheme.Colors.backgroundDark.ignoresSafeArea()
                
                VStack {
                    ZStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                            .buttonStyle(KineticButtonStyle())
                            
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                            }, label: {
                                HStack {
                                    Text("FINISH")
                                    Image(systemName: "flag.checkered")
                                }
                                .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.Colors.backgroundDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(AppTheme.Colors.bluePrimary)
                                .clipShape(Capsule())
                            })
                            .buttonStyle(KineticButtonStyle())
                        }
                        .padding(.horizontal)

                        Text("Custom Protocol")
                            .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Text(workout.exercises[currentExerciseIndex].name)
                            .font(AppTheme.Typography.telemetry(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                    
                    CustomWorkoutExerciseDataSetWidget(exerciseData: self.$exerciseData, isWeight: workout.exercises[currentExerciseIndex].isWeight) {
                        if currentExerciseIndex + 1 < workout.exercises.count {
                            Task {
                                addToGymSession()
                            }
                            
                            currentExerciseIndex += 1
                            self.exerciseData = ExerciseData(sets: [])
                        }
                        else {
                            Task {
                                addToGymSession()
                            }
                            
                            
                            dismiss()
                        }
                    }
                    
                    Spacer()
                }
            }
        } else {
            VStack {
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
                
                Spacer()
            }
        }
    }
    
    @MainActor func addToGymSession() {
        guard let currentSession = GymManager.shared.currentSession, let currentExercise = workout?.exercises[currentExerciseIndex]  else {
            print("No active gym session found.")
            return
        }

        let exerciseRecord = ExerciseRecord(
            exerciseInfo: .libraryExercise(Progression(name: currentExercise.name, description: "", level: 0, cdnURL: "", exerciseType: "", isWeight: currentExercise.isWeight)),
            exerciseData: exerciseData
        )

        GymManager.shared.currentSession?.addIndividualExercise(exerciseRecord: exerciseRecord)
        GymManager.shared.saveGymSession(currentSession)
        
        print("Exercise added to current session.")
    }
}

#Preview {
    CustomWorkoutView(workout: CustomWorkout(name: "", image: nil, exercises: []))
}
