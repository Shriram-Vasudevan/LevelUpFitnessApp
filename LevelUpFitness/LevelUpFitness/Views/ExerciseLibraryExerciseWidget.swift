//
//  ExerciseLibraryExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct ExerciseLibraryExerciseWidget: View {
    var exerciseLibraryExercise: ExerciseLibraryExercise
    var userXPData: XPData
    
    var exerciseSelected: () -> Void
    
    var body: some View {
        HStack {
            Image("GuyAtTheGym")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(5)
                
//            VStack (alignment: .leading, spacing: 5) {
//                Text(exerciseLibraryExercise.name)
//                    .font(.headline)
//                
//                Text(exerciseLibraryExercise.description)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                
//                HStack {
//                    Text("Level \(exerciseLibraryExercise.level)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                    
//                    if isLocked {
//                        Image(systemName: "lock.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 15)
//                            .foregroundColor(.gray)
//                          
//                    }
//                    
//                    Spacer()
//                }
//            }
//            .frame(height: 60)
//            
            Spacer()
        }
        .padding(.horizontal)
        //.opacity(isLocked ? 0.6 : 1.0)
        .onTapGesture {
//            if !isLocked {
//                exerciseSelected()
//            }
        }
    }
    
    func getExerciseTypeLevel(for exerciseType: String) -> Int {
        switch exerciseType.lowercased() {
        case "lower body compound":
            return userXPData.subLevels.lowerBodyCompound.level
        case "lower body isolation":
            return userXPData.subLevels.lowerBodyIsolation.level
        case "upper body compound":
            return userXPData.subLevels.upperBodyCompound.level
        case "upper body isolation":
            return userXPData.subLevels.upperBodyIsolation.level
        default:
            return 0
        }
    }
    
    func isLocked(progression: Progression) -> Bool {
        let exerciseTypeLevel = getExerciseTypeLevel(for: exerciseLibraryExercise.exerciseType)
        return exerciseTypeLevel < progression.level
    }
}

#Preview {
    ExerciseLibraryExerciseWidget(
        exerciseLibraryExercise: ExerciseLibraryExercise(id: "", name: "", exerciseType: "", progression: [Progression(name: "", description: "", level: 5, cdnURL: "", exerciseType: "")]),
        userXPData: XPData(
            userID: "",
            level: 2,
            xp: 0,
            xpNeeded: 50,
            subLevels: Sublevels(
                lowerBodyCompound: XPAttribute(xp: 0, level: 0, xpNeeded: 0),
                lowerBodyIsolation: XPAttribute(xp: 0, level: 0, xpNeeded: 0),
                upperBodyCompound: XPAttribute(xp: 0, level: 2, xpNeeded: 0),
                upperBodyIsolation: XPAttribute(xp: 0, level: 0, xpNeeded: 0)
            )
        ),
        exerciseSelected: {}
    )
}
