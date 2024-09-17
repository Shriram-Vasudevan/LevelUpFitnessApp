//
//  CreateCustomWorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/16/24.
//

import SwiftUI

struct CreateCustomWorkoutView: View {
    @State private var workoutName: String = ""
    @State private var exercises: [CustomWorkoutExercise] = []
    @State private var newExerciseName: String = ""
    @State private var isWeight: Bool = false

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    Text("Create Custom Workout")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(hex: "40C4FC"))
                            .frame(width: 30, height: 30)
                            .background(Color(hex: "40C4FC").opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.vertical, 8)
                
                inputField(title: "Workout Name", text: $workoutName, unit: "")

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(exercises.indices, id: \.self) { index in
                            exerciseRow(for: exercises[index], at: index)
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    HStack {
                        inputField(title: "Exercise Name", text: $newExerciseName, unit: "")
                        
                        HStack {
                            Button(action: {
                                isWeight.toggle()
                            }) {
                                Image(systemName: isWeight ? "dumbbell.fill" : "figure.walk")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(isWeight ? Color(hex: "40C4FC") : .gray)
                            }
                            .padding(8)
                            .background(Color(hex: "F5F5F5"))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "40C4FC"), lineWidth: 1)
                            )
                        }
                        .frame(width: 60)
                        
                        Spacer()
                    }
                    HStack {
                        Button(action: {
                            if !newExerciseName.isEmpty {
                                let exercise = CustomWorkoutExercise(name: newExerciseName, isWeight: isWeight)
                                exercises.append(exercise)
                                newExerciseName = ""
                                isWeight = false
                            }
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Exercise")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .padding()
                            .foregroundColor(Color(hex: "40C4FC"))
                            .background(Color(hex: "40C4FC").opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.vertical, 8)

                Button(action: {
                    let customWorkout = CustomWorkout(name: workoutName, exercises: exercises)
                    CustomWorkoutManager.shared.addCustomWorkout(workout: customWorkout)
                    
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Create Workout")
                            .font(.system(size: 18, weight: .medium))
                        Spacer()
                    }
                    .padding()
                    .background(Color(hex: "40C4FC"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
            .padding()
        }
    }

    private func exerciseRow(for exercise: CustomWorkoutExercise, at index: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .medium))
                Text(exercise.isWeight ? "Uses Weights" : "Bodyweight")
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                exercises.remove(at: index)
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }

    private func inputField(title: String, text: Binding<String>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light, design: .default))
                .foregroundColor(.secondary)
            HStack {
                TextField("Enter", text: text)
                    .keyboardType(.default)
                    .font(.system(size: 18, weight: .medium, design: .default))
                Text(unit)
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CreateCustomWorkoutView()
}
