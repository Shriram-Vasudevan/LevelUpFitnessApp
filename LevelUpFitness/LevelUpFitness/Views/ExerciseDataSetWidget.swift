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
    
    @State private var isExercising = false
    @State private var isResting = false
    @State private var elapsedTime: Double = 0.0
    @State private var timer: Timer?
    @State private var weightText = ""
    @State private var repText = ""
    
    let setIndex: Int
    let totalSets: Int
    let setCompleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            equipmentView
            areaAndRepsView
            timerView
            inputFieldsView
            actionButton
        }
        .padding()
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Set \(setIndex + 1) / \(totalSets)")
                    .font(.system(size: 20, weight: .medium, design: .default))
                Text(isResting ? "Rest" : "Exercise")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: isResting ? "hourglass" : "figure.walk")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: "40C4FC"))
        }
    }
    
    private var equipmentView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(exercise.equipment, id: \.self) { equipment in
                    HStack(spacing: 4) {
                        Image(systemName: "dumbbell.fill")
                            .foregroundColor(Color(hex: "40C4FC"))
                        Text(equipment)
                            .font(.system(size: 14, weight: .light, design: .default))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color(hex: "40C4FC").opacity(0.1))
                }
            }
        }
    }
    
    private var timerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Time")
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.secondary)
                Text(String(format: "%.1f", elapsedTime))
                    .font(.system(size: 24, weight: .medium, design: .default))
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .opacity(0.3)
                    .foregroundColor(Color(hex: "40C4FC"))
                
                Circle()
                    .trim(from: 0.0, to: min(CGFloat(elapsedTime) / 60.0, 1.0))
                    .stroke(style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color(hex: "40C4FC"))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: elapsedTime)
            }
            .frame(width: 50, height: 50)
        }
    }
    
    private var inputFieldsView: some View {
        HStack(spacing: 16) {
            if exercise.isWeight {
                inputField(title: "Weight", text: $weightText, unit: "lbs")
            }
            inputField(title: "Reps", text: $repText, unit: "reps")
        }
    }
    
    private func inputField(title: String, text: Binding<String>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light, design: .default))
                .foregroundColor(.secondary)
            HStack {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .medium, design: .default))
                Text(unit)
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
        }
    }
    
    private var areaAndRepsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Area")
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.secondary)
                Text(exercise.area)
                    .font(.system(size: 16, weight: .medium, design: .default))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text("Recommended Reps")
                    .font(.system(size: 14, weight: .light, design: .default))
                    .foregroundColor(.secondary)
                Text(exercise.reps)
                    .font(.system(size: 16, weight: .medium, design: .default))
            }
        }
        .padding(.top, 8)
    }
    
    private var actionButton: some View {
        Button(action: handleSetCompletion) {
            Text(buttonTitle)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonColor)
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
        else { return Color(hex: "40C4FC") }
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
    ProgramExerciseDataSetWidget(model: .constant(ExerciseDataSet(weight: 10, reps: 5, time: 0.0, rest: 0.0)), exercise: ProgramExercise(name: "", sets: 0, reps: "0", rpe: "", rest: 0, area: "", isWeight: true, completed: false, cdnURL: "", equipment: [""], data: ExerciseData(sets: [])), setIndex: 0, totalSets: 1, setCompleted: {})
}
