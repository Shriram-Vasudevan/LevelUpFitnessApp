//
//  ExerciseLibraryExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct ExerciseLibraryExerciseWidget: View {
    var exerciseLibraryExercise: ExerciseLibraryExerciseDownloaded
    var userXPData: XPData
    
    var isLocked: Bool {
        let bodyAreaLevel = getBodyAreaLevel(for: exerciseLibraryExercise.bodyArea)
        return bodyAreaLevel < exerciseLibraryExercise.level
    }
    
    var exerciseSelected: () -> Void
    
    var body: some View {
        HStack {
            Image("GuyAtTheGym")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(5)
                
            VStack (alignment: .leading, spacing: 5) {
                Text(exerciseLibraryExercise.name)
                    .font(.headline)
                
                Text(exerciseLibraryExercise.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("Level \(exerciseLibraryExercise.level)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 15)
                            .foregroundColor(.gray)
                          
                    }
                    
                    Spacer()
                }
            }
            .frame(height: 60)
            
            Spacer()
        }
        .padding(.horizontal)
        .opacity(isLocked ? 0.6 : 1.0)
        .onTapGesture {
            if !isLocked {
                exerciseSelected()
            }
        }
    }
    
    func getBodyAreaLevel(for bodyArea: String) -> Int {
        switch bodyArea.lowercased() {
        case "back":
            return userXPData.subLevels.bodyAreas.back.level
        case "legs":
            return userXPData.subLevels.bodyAreas.legs.level
        case "chest":
            return userXPData.subLevels.bodyAreas.chest.level
        case "shoulders":
            return userXPData.subLevels.bodyAreas.shoulders.level
        case "core":
            return userXPData.subLevels.bodyAreas.core.level
        default:
            return 0
        }
    }
}

#Preview {
    ExerciseLibraryExerciseWidget(exerciseLibraryExercise: ExerciseLibraryExerciseDownloaded(id: "Test", name: "Push-up", videoURL: URL(string: "Test")!, description: "Develops upper body and back muscles · Advanced", bodyArea: "", level: 3), userXPData: XPData(userID: "", level: 2, xp: 0, xpNeeded: 50, subLevels: Sublevels(mobility: XPAttribute(xp: 0, level: 0, xpNeeded: 0), endurance: XPAttribute(xp: 0, level: 0, xpNeeded: 0), strength: XPAttribute(xp: 0, level: 0, xpNeeded: 0), bodyAreas: BodyAreas(back: XPAttribute(xp: 0, level: 0, xpNeeded: 0), legs: XPAttribute(xp: 0, level: 0, xpNeeded: 0), chest: XPAttribute(xp: 0, level: 0, xpNeeded: 0), shoulders: XPAttribute(xp: 0, level: 0, xpNeeded: 0), core: XPAttribute(xp: 0, level: 0, xpNeeded: 0)))), exerciseSelected: {})
}
