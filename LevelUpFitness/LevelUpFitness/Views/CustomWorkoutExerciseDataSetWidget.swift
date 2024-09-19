//
//  CustomWorkoutExerciseDataSetWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/18/24.
//

import SwiftUI

struct CustomWorkoutExerciseDataSetWidget: View {
    @State var sectionType: ExerciseDataSectionType = .start
    @State var exerciseData: ExerciseData
    
    @State var numberOfSets: String = ""
    @State var setsFieldNotFilledOut: Bool = false
    @State var currentExerciseDataSetIndex: Int = 0

    var isWeight: Bool
    var exerciseFinished: () -> Void
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
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
                .font(.system(size: 20, weight: .medium, design: .default))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Number of Sets")
                    .font(.system(size: 16, weight: .light, design: .default))
                    .foregroundColor(.secondary)
                
                TextField("", text: $numberOfSets)
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .padding()
                    .background(Color(hex: "F5F5F5"))
                    .overlay(
                        Rectangle()
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
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
            }
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
        VStack(spacing: 24) {
            Text("Exercise Complete!")
                .font(.system(size: 20, weight: .medium, design: .default))
            
            Text("Great job! You've finished all your sets.")
                .font(.system(size: 16, weight: .light, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: {
                self.exerciseData = ExerciseData(sets: [])
                exerciseFinished()
            }) {
                Text("Continue")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
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


#Preview {
    CustomWorkoutExerciseDataSetWidget(exerciseData: ExerciseData(sets: []), isWeight: false, exerciseFinished: {})
}
