//
//  LibraryExerciseDataView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/25/24.
//

import SwiftUI

struct LibraryExerciseDataView: View {
    @State var sectionType: LibraryExerciseDataSectionType = .start
    @State var exerciseData: ExerciseData
    @State var numberOfSets: String = ""
    @State var setsFieldNotFilledOut: Bool = false
    @State var currentExerciseDataSetIndex: Int = 0
    var isWeight: Bool
    var exerciseType: String
    
    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            
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
    }
    
    var startView: some View {
        VStack(spacing: 24) {
            Text("Set up your exercise")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Sets")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                TextField("", text: $numberOfSets)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(hex: "F5F5F5"))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(setsFieldNotFilledOut ? Color.red : Color.clear, lineWidth: 2)
                    )
            }
            
            Button(action: {
                if !numberOfSets.isEmpty {
                    setsFieldNotFilledOut = false
                    initializeExerciseData(numberOfSets: numberOfSets)
                    sectionType = .inProgress
                } else {
                    setsFieldNotFilledOut = true
                }
            }) {
                Text("Begin Sets")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(15)
            }
        }
    }
    
    var inProgressView: some View {
        LibraryExerciseDataSetWidget(
            exerciseDataSet: $exerciseData.sets[currentExerciseDataSetIndex],
            isWeight: isWeight,
            setIndex: currentExerciseDataSetIndex,
            moveToNextSet: {
                if !(currentExerciseDataSetIndex == exerciseData.sets.count - 1) {
                    currentExerciseDataSetIndex += 1
                } else {
                    let xpAdditionType = getExerciseTypeEnum(exerciseType: exerciseType)
                    
                    Task {
                        await XPManager.shared.addXP(increment: 5, type: xpAdditionType)
                        await XPManager.shared.addXPToDB()
                    }
                    
                    sectionType = .finished
                }
            }
        )
    }
    
    var finishedView: some View {
        VStack(spacing: 30) {
            Text("Exercise Complete!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            Text("Great job! You've finished all your sets.")
                .font(.system(size: 18, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                self.exerciseData = ExerciseData(sets: [])
                sectionType = .start
            }) {
                Text("Start New Exercise")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(15)
            }
        }
    }
    
    func initializeExerciseData(numberOfSets: String) {
        guard let numSets = Int(numberOfSets) else { return }
        self.exerciseData = ExerciseData(sets: Array(repeating: ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0), count: numSets))
    }
    
    func getExerciseTypeEnum(exerciseType: String) -> XPAdditionType {
        switch exerciseType {
        case "Lower Body Compound":
            return .lowerBodyCompound
        default:
            return .lowerBodyCompound
        }
    }
}

struct LibraryExerciseDataSetWidget: View {
    @Binding var exerciseDataSet: ExerciseDataSet
    @State var weightText: String = ""
    @State var repText: String = ""
    @State var weightFieldNotFilledOut: Bool = false
    @State var repsFieldNotFilledOut: Bool = false
    @State var isWeight: Bool
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    @State var exerciseTime: Double = 0.0
    @State var restTime: Double = 0.0
    @State var isExercising: Bool = false
    @State var isResting: Bool = false
    var setIndex: Int
    var moveToNextSet: () -> Void
    
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
                Image(systemName: isResting ? "hourglass" : "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "40C4FC"))
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
            
            HStack(spacing: 20) {
                if isWeight {
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
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(12)
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
            .background(Color.white)
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
            if (!weightText.isEmpty && isWeight && !repText.isEmpty) || (!repText.isEmpty && !isWeight) {
                stopTimer()
                isResting = false
                saveData()
                moveToNextSet()
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
        exerciseDataSet.weight = Int(weightText) ?? 0
        exerciseDataSet.reps = Int(repText) ?? 0
        exerciseDataSet.time = exerciseTime
        exerciseDataSet.rest = restTime
    }
}

#Preview {
    LibraryExerciseDataView(exerciseData: ExerciseData(sets: []), isWeight: false, exerciseType: "LowerBody")
}
