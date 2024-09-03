//
//  LibraryView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    @ObservedObject var exerciseManager: ExerciseManager
    
    @State var selectedExercise: Progression?
    
    let exerciseTypeKeys = [
        Sublevels.CodingKeys.lowerBodyCompound.rawValue,
        Sublevels.CodingKeys.lowerBodyIsolation.rawValue,
        Sublevels.CodingKeys.upperBodyCompound.rawValue,
        Sublevels.CodingKeys.upperBodyIsolation.rawValue
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    HStack {
                        Text("Exercise Library")
                            .font(.custom("Sailec Medium", size: 30))
                        Spacer()
                        Image(systemName: "bell")
                            .font(.system(size: 20))
                            .foregroundColor(.secondary)
                    }
                    
                    if let userXPData = xpManager.userXPData {
                        ForEach(exerciseTypeKeys, id: \.self) { key in
                            exerciseCategoryView(for: key, userXPData: userXPData)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemBackground))
            .navigationDestination(item: $selectedExercise) { exercise in
                IndividualExerciseView(progression: exercise)
            }
        }
    }
    
    
    private func exerciseCategoryView(for key: String, userXPData: XPData) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(key.capitalizingFirstLetter())
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                Spacer()
                if let level = userXPData.subLevels.attribute(for: key)?.level {
                    Text("Level \(level)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            let filteredExercises = exerciseManager.exercises.filter { $0.exerciseType == key.capitalizingFirstLetter() }
            if filteredExercises.isEmpty {
                Text("No exercises for \(key)")
                    .foregroundColor(.secondary)
            } else {
                ForEach(filteredExercises, id: \.id) { exercise in
                    ExerciseLibraryExerciseWidget(exercise: exercise, userXPData: userXPData) { progression in
                        self.selectedExercise = progression
                    }
                }
            }
        }
    }
}

#Preview {
    LibraryView(programManager: ProgramManager(), xpManager: XPManager(), exerciseManager: ExerciseManager())
}
