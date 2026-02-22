//
//  LibraryExerciseDataView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/25/24.
//

import SwiftUI


struct LibraryExerciseDataView: View {
    @State var sectionType: ExerciseDataSectionType = .start
    @State var progression: Progression
    @State var exerciseData: ExerciseData
    
    @State var numberOfSetsValue: Int = 3
    
    @State var currentExerciseDataSetIndex: Int = 0
    var isWeight: Bool
    var exerciseType: String
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()
            
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
        VStack(spacing: 32) {
            
            VStack(spacing: 8) {
                Text("Session Setup")
                    .font(AppTheme.Typography.telemetry(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text(progression.name)
                    .font(AppTheme.Typography.telemetry(size: 16))
                    .foregroundColor(AppTheme.Colors.bluePrimary)
            }
            .multilineTextAlignment(.center)
            
            VStack(spacing: 24) {
                KineticStepper(title: "Target Sets", value: $numberOfSetsValue, step: 1, unit: "sets")
                
                Button(action: {
                    if numberOfSetsValue > 0 {
                        initializeExerciseData(numberOfSets: numberOfSetsValue)
                        sectionType = .inProgress
                    }
                }) {
                    HStack {
                        Text("Begin Protocol")
                        Image(systemName: "arrow.right")
                    }
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
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
            
            Spacer()
        }
        .padding(.top, 40)
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
                    let xpAdditionType = getExerciseTypeEnum(exerciseType: exerciseType)
                
                    Task {
                        await addToGymSession()
                        await XPManager.shared.addXP(increment: 2, type: xpAdditionType)
                        await XPManager.shared.addXP(increment: 2, type: .total)
                    }
                    
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
                
                Text("Performance logged and synced to telemetry.")
                    .font(AppTheme.Typography.telemetry(size: 16))
                    .multilineTextAlignment(.center)
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            
            Button(action: {
                self.exerciseData = ExerciseData(sets: [])
                sectionType = .start
                currentExerciseDataSetIndex = 0
            }) {
                Text("Start Another Exercise")
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
    
    func getExerciseTypeEnum(exerciseType: String) -> XPAdditionType {
        switch exerciseType {
        case "Lower Body Compound":
            return .lowerBodyCompound
        default:
            return .lowerBodyCompound
        }
    }
    
    @MainActor func addToGymSession() {
        guard let currentSession = GymManager.shared.currentSession else {
            print("No active gym session found.")
            return
        }

        let exerciseRecord = ExerciseRecord(
            exerciseInfo: .libraryExercise(progression),
            exerciseData: exerciseData
        )

        GymManager.shared.currentSession?.addIndividualExercise(exerciseRecord: exerciseRecord)
        GymManager.shared.saveGymSession(currentSession)

        print("Exercise added to current session.")
    }
}

// Rewritten fast, tactile logger for Library Exercises
struct LibraryExerciseDataSetWidget: View {
    @Binding var exerciseDataSet: ExerciseDataSet
    
    @State private var weightValue: Int = 0
    @State private var repValue: Int = 0
    @State private var restTimeElapsed: Double = 0.0
    @State private var timer: Timer?
    
    var isWeight: Bool
    var setIndex: Int
    var totalSets: Int
    var moveToNextSet: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            if setIndex > 0 {
                restTimerIndicator
            }
            
            inputFieldsView
            
            actionButton
        }
        .padding(20)
        .engineeredPanel(isElevated: true)
        .onAppear {
            weightValue = exerciseDataSet.weight > 0 ? exerciseDataSet.weight : 0
            repValue = exerciseDataSet.reps > 0 ? exerciseDataSet.reps : 10
            
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
    
    private var inputFieldsView: some View {
        VStack(spacing: 16) {
            if isWeight {
                KineticStepper(title: "Weight (lbs)", value: $weightValue, step: 5, unit: "lbs")
            }
            KineticStepper(title: "Reps", value: $repValue, step: 1, unit: "reps")
        }
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
        exerciseDataSet.weight = weightValue
        exerciseDataSet.reps = repValue
        exerciseDataSet.rest = restTimeElapsed
        exerciseDataSet.time = 0
        
        stopRestTimer()
        moveToNextSet()
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

#Preview {
    LibraryExerciseDataView(progression: Progression(name: "", description: "", level: 0, cdnURL: "", exerciseType: "", isWeight: false), exerciseData: ExerciseData(sets: []), isWeight: false, exerciseType: "LowerBody")
}
