//
//  CreateCustomWorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/16/24.
//

import SwiftUI
import PhotosUI

struct CreateCustomWorkoutView: View {
    @State private var workoutName: String = ""
    @State private var exercises: [CustomWorkoutExercise] = []
    
    @State private var showingExercisePicker = false
    
    @State private var selectedWorkoutImage: PhotosPickerItem?
    @State private var workoutImageData: Data? = nil
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()

            VStack(spacing: 20) {
                // MARK: - Header
                HStack {
                    Text("Design Program")
                        .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)

                    Spacer()

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // MARK: - Workout Identity
                VStack(spacing: 16) {
                    inputField(title: "Program Designation", text: $workoutName, placeholder: "e.g. Tactical Barbell")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Module Identity Art")
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        PhotosPicker(selection: $selectedWorkoutImage, matching: .images, photoLibrary: .shared()) {
                            if let imageData = workoutImageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .frame(maxWidth: .infinity)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppTheme.Colors.bluePrimary)
                                    Text("Select Cover Image")
                                        .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .background(AppTheme.Colors.surfaceLight)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [4]))
                                )
                            }
                        }
                        .buttonStyle(KineticButtonStyle())
                    }
                }
                .padding(.horizontal)

                // MARK: - Exercise Sequence
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Protocol Sequence")
                            .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Spacer()
                        
                        Text("\(exercises.count) Nodes")
                            .font(AppTheme.Typography.monumentalNumber(size: 14))
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                    }
                    .padding(.horizontal)
                    
                    if exercises.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "square.stack.3d.up.slash")
                                .font(.system(size: 32))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                            Text("Sequence Empty")
                                .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .background(AppTheme.Colors.surfaceLight)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(exercises.indices, id: \.self) { index in
                                    exerciseRow(for: exercises[index], at: index)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // MARK: - Append Action
                Button(action: {
                    showingExercisePicker = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "plus")
                        Text("Append Exercise")
                        Spacer()
                    }
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
                    .padding()
                    .background(AppTheme.Colors.bluePrimary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.Colors.bluePrimary.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(KineticButtonStyle())
                .padding(.horizontal)

                Spacer()

                // MARK: - Commit Action
                Button(action: {
                    if !exercises.isEmpty && !workoutName.isEmpty {
                        let customWorkout = CustomWorkout(name: workoutName, image: workoutImageData, exercises: exercises)
                        CustomWorkoutManager.shared.addCustomWorkout(workout: customWorkout)
                        dismiss()
                    }
                }) {
                    HStack {
                        Spacer()
                        Text("Compile & Save")
                            .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                        Spacer()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(exercises.isEmpty || workoutName.isEmpty ? AppTheme.Colors.surfaceLight : AppTheme.Colors.bluePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .controlledGlow(isActive: !exercises.isEmpty && !workoutName.isEmpty)
                }
                .buttonStyle(KineticButtonStyle())
                .disabled(exercises.isEmpty || workoutName.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .sheet(isPresented: $showingExercisePicker) {
            LibraryExercisePicker { progression in
                let newExercise = CustomWorkoutExercise(
                    name: progression.name,
                    isWeight: progression.isWeight,
                    progression: progression
                )
                exercises.append(newExercise)
            }
        }
        .onChange(of: selectedWorkoutImage) { _ in
            Task {
                if let data = try? await selectedWorkoutImage?.loadTransferable(type: Data.self) {
                    self.workoutImageData = data
                }
            }
        }
    }

    private func exerciseRow(for exercise: CustomWorkoutExercise, at index: Int) -> some View {
        HStack {
            Text("\(index + 1)")
                .font(AppTheme.Typography.monumentalNumber(size: 16))
                .foregroundColor(AppTheme.Colors.bluePrimary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.walk")
                        .font(.system(size: 10))
                    Text(exercise.isWeight ? "Weighted" : "Bodyweight")
                }
                .font(AppTheme.Typography.telemetry(size: 12))
                .foregroundColor(AppTheme.Colors.textSecondary)
            }

            Spacer()

            Button(action: {
                withAnimation {
                    exercises.remove(at: index)
                }
            }) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(AppTheme.Colors.danger)
                    .font(.system(size: 24))
            }
            .buttonStyle(KineticButtonStyle())
        }
        .padding()
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            TextField(placeholder, text: text)
                .font(AppTheme.Typography.telemetry(size: 18, weight: .medium))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .padding()
                .background(AppTheme.Colors.surfaceLight)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        }
    }
}

#Preview {
    CreateCustomWorkoutView()
}
