//
//  ExerciseDataSetWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/5/24.
//

import SwiftUI


import SwiftUI

struct ProgramExerciseDataSetWidget: View {
    @Binding var model: ExerciseDataSet
    let exercise: ProgramExercise
    
    @State private var isExercising = false
    @State private var isResting = false
    @State private var elapsedTime: Double = 0.0
    @State private var timer: Timer?
    @State private var weightText = ""
    @State private var repText = ""
    
    let setIndex: Int
    let setCompleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Set \(setIndex + 1)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text(isResting ? "Rest" : "Exercise")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                Spacer()
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            }
            
            if exercise.equipment != "none" {
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.blue)
                    Text(exercise.equipment)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Time")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", elapsedTime))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                }
                Spacer()
                ZStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .opacity(0.3)
                        .foregroundColor(.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: min(CGFloat(elapsedTime) / 60.0, 1.0))
                        .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: elapsedTime)
                }
                .frame(width: 50, height: 50)
            }
            
            HStack(spacing: 20) {
                if exercise.isWeight {
                    inputField(title: "Weight", text: $weightText, unit: "kg")
                }
                inputField(title: "Reps", text: $repText, unit: "reps")
            }
            
            Button(action: handleSetCompletion) {
                HStack {
                    Spacer()
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Spacer()
                }
                .padding()
                .background(buttonColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    
    private func inputField(title: String, text: Binding<String>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            HStack {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(unit)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var buttonTitle: String {
        if isResting { return "Continue" }
        else if isExercising { return "Begin Rest" }
        else { return "Begin Exercise" }
    }
    
    private var buttonColor: Color {
        if isResting { return .green }
        else if isExercising { return .red }
        else { return .blue }
    }
    
    private func handleSetCompletion() {
        if !isExercising && !isResting {
            startTimer(for: "time")
            isExercising = true
        } else if isExercising {
            stopTimer()
            isExercising = false
            isResting = true
            startTimer(for: "rest")
        } else if isResting {
            if (!weightText.isEmpty && exercise.isWeight && !repText.isEmpty) || (!repText.isEmpty && !exercise.isWeight) {
                stopTimer()
                isResting = false
                saveData()
                setCompleted()
            }
        }
    }
    
    private func startTimer(for type: String) {
        elapsedTime = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func saveData() {
        model.weight = Int(weightText) ?? 0
        model.reps = Int(repText) ?? 0
        model.time = elapsedTime
        model.rest = elapsedTime
    }
}



#Preview {
    ProgramExerciseDataSetWidget(model: .constant(ExerciseDataSet(weight: 10, reps: 5, time: 0.0, rest: 0.0)), exercise: ProgramExercise(name: "", sets: 0, reps: 0, rpe: "", rest: 0, area: "", isWeight: true, completed: false, cdnURL: "", equipment: "", data: ExerciseData(sets: [])), setIndex: 0, setCompleted: {})
}
