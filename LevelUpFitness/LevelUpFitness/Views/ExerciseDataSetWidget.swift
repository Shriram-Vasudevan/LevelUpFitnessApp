//
//  ExerciseDataSetWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/5/24.
//

import SwiftUI

struct ProgramExerciseDataSetWidget: View {
    @Binding var model: ExerciseDataSet
    let exercise: ProgramExercise
    
    @State private var weightValue: Int = 0
    @State private var repValue: Int = 0
    
    @State private var restTimeElapsed: Double = 0.0
    @State private var timer: Timer?
    
    let setIndex: Int
    let totalSets: Int
    let setCompleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            if setIndex > 0 {
                restTimerIndicator
            }
            
            equipmentView
            areaAndRepsView
            
            inputFieldsView
            
            actionButton
        }
        .padding(20)
        .engineeredPanel(isElevated: true)
        .onAppear {
            // Inherit from previous set if possible, else 0
            weightValue = model.weight > 0 ? model.weight : 0
            repValue = model.reps > 0 ? model.reps : (Int(exercise.reps) ?? 10)
            
            if setIndex > 0 {
                startRestTimer()
            }
        }
        .onDisappear {
            stopRestTimer()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Set \(setIndex + 1) / \(totalSets)")
                    .font(AppTheme.Typography.telemetry(size: 20, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text("Log your performance")
                    .font(AppTheme.Typography.telemetry(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
            
            Image(systemName: "bolt.fill")
                .font(.system(size: 24))
                .foregroundColor(AppTheme.Colors.bluePrimary)
                .controlledGlow(isActive: true)
        }
    }
    
    private var restTimerIndicator: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundColor(AppTheme.Colors.bluePrimary)
            Text("Resting: \(timeFormatted(restTimeElapsed))")
                .font(AppTheme.Typography.monumentalNumber(size: 16))
                .foregroundColor(AppTheme.Colors.bluePrimary)
            Spacer()
        }
        .padding(12)
        .background(AppTheme.Colors.bluePrimary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
    
    private var equipmentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(exercise.equipment, id: \.self) { equipment in
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(AppTheme.Colors.bluePrimary)
                        Text(equipment)
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 16) {
            if exercise.isWeight {
                KineticStepper(title: "Weight (lbs)", value: $weightValue, step: 5, unit: "lbs")
            }
            KineticStepper(title: "Reps", value: $repValue, step: 1, unit: "reps")
        }
    }
    
    private var areaAndRepsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Target Area")
                    .font(AppTheme.Typography.telemetry(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(exercise.area)
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Target Reps")
                    .font(AppTheme.Typography.telemetry(size: 14))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                Text(exercise.reps)
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
    
    private var actionButton: some View {
        Button(action: handleSetCompletion) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                Text("Log Set & Rest")
            }
            .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.Colors.bluePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(KineticButtonStyle())
        .padding(.top, 8)
    }
    
    private func handleSetCompletion() {
        // Save the fast entry values to the model
        model.weight = weightValue
        model.reps = repValue
        model.rest = restTimeElapsed
        model.time = 0 // Optional: Could track active time if needed, but not required for simple flow
        
        stopRestTimer()
        setCompleted()
    }
    
    private func startRestTimer() {
        restTimeElapsed = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            restTimeElapsed += 1.0
        }
    }
    
    private func stopRestTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timeFormatted(_ totalSeconds: Double) -> String {
        let seconds = Int(totalSeconds) % 60
        let minutes = Int(totalSeconds) / 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

/// A highly tactile, mechanical stepper for fast numerical input
struct KineticStepper: View {
    let title: String
    @Binding var value: Int
    let step: Int
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)
            
            HStack(spacing: 0) {
                Button(action: {
                    if value - step >= 0 {
                        value -= step
                        triggerHaptic()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(width: 60, height: 60)
                        .contentShape(Rectangle())
                }
                .buttonStyle(KineticButtonStyle())
                
                Spacer()
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(value)")
                        .font(AppTheme.Typography.monumentalNumber(size: 36))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .contentTransition(.numericText(value: Double(value)))
                        .animation(.snappy, value: value)
                    
                    Text(unit)
                        .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                }
                
                Spacer()
                
                Button(action: {
                    value += step
                    triggerHaptic()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .frame(width: 60, height: 60)
                        .contentShape(Rectangle())
                }
                .buttonStyle(KineticButtonStyle())
            }
            .background(AppTheme.Colors.surfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
        }
    }
    
    private func triggerHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }
}

#Preview {
    ProgramExerciseDataSetWidget(model: .constant(ExerciseDataSet(weight: 10, reps: 5, time: 0.0, rest: 0.0)), exercise: ProgramExercise(name: "", sets: 0, reps: "10-12", rpe: "", rest: 0, area: "Chest", isWeight: true, completed: false, cdnURL: "", equipment: ["Dumbbells"], description: "", data: ExerciseData(sets: [])), setIndex: 1, totalSets: 4, setCompleted: {})
}
