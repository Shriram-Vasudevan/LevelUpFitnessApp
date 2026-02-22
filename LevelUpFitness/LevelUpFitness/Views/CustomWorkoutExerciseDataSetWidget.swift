//
//  CustomWorkoutExerciseDataSetWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/18/24.
//

import SwiftUI

struct CustomWorkoutExerciseDataSetWidget: View {
    @State var sectionType: ExerciseDataSectionType = .start
    @Binding var exerciseData: ExerciseData
    
    @State var numberOfSetsValue: Int = 3
    @State var currentExerciseDataSetIndex: Int = 0

    var isWeight: Bool
    var exerciseFinished: () -> Void
    
    var body: some View {
        VStack {
            switch sectionType {
                case .start:
                    startView
                case .inProgress:
                    inProgressView
                case .finished:
                    finishedView
            }
        }
        .padding()
    }
    
    var startView: some View {
        VStack(spacing: 32) {
            Text("Set up your exercise")
                .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 24) {
                KineticStepper(title: "Target Sets", value: $numberOfSetsValue, step: 1, unit: "sets")
                
                Button(action: {
                    if numberOfSetsValue > 0 {
                        initializeExerciseData(numberOfSets: numberOfSetsValue)
                        sectionType = .inProgress
                    }
                }) {
                    Text("Begin Sets")
                        .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.Colors.bluePrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(KineticButtonStyle())
            }
            .padding(20)
            .engineeredPanel(isElevated: true)
        }
    }
    
    var inProgressView: some View {
        LibraryExerciseDataSetWidget(
            exerciseDataSet: $exerciseData.sets[currentExerciseDataSetIndex],
            isWeight: isWeight,
            setIndex: currentExerciseDataSetIndex,
            totalSets: exerciseData.sets.count,
            moveToNextSet: {
                if currentExerciseDataSetIndex < exerciseData.sets.count - 1 {
                    currentExerciseDataSetIndex += 1
                } else {
                    sectionType = .finished
                }
            }
        )
    }
    
    var finishedView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(AppTheme.Colors.success)
                .controlledGlow(isActive: true, color: AppTheme.Colors.success.opacity(0.4))

            VStack(spacing: 8) {
                Text("Exercise Complete!")
                    .font(AppTheme.Typography.telemetry(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Great job! You've finished all your sets.")
                    .font(AppTheme.Typography.telemetry(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Button(action: {
                self.exerciseData = ExerciseData(sets: [])
                exerciseFinished()
                
                sectionType = .start
            }) {
                Text("Continue to Next Exercise")
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.Colors.bluePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(KineticButtonStyle())
            .padding(20)
            .engineeredPanel(isElevated: true)
        }
    }
    
    func initializeExerciseData(numberOfSets: Int) {
        self.exerciseData = ExerciseData(sets: Array(repeating: ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0), count: numberOfSets))
    }
}

#Preview {
    CustomWorkoutExerciseDataSetWidget(exerciseData: .constant(ExerciseData(sets: [])), isWeight: false, exerciseFinished: {})
}
