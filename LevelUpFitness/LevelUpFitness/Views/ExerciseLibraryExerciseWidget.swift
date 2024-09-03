//
//  ExerciseLibraryExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI


struct ExerciseLibraryExerciseWidget: View {
    var exercise: ExerciseLibraryExercise
    var userXPData: XPData
    var exerciseSelected: (Progression) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let progression = getMainProgression() {
                HStack(spacing: 16) {
                    Image("GuyAtTheGym")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(progression.name)
                            .font(.headline)
                        Text("Level \(progression.level)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    exerciseSelected(progression)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(getOtherProgressions(), id: \.self) { progression in
                        VStack(spacing: 8) {
                            Image("GuyAtTheGym")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Text(progression.name)
                                .font(.caption)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            
                            Text("Level \(progression.level)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            if isLocked(progression: progression) {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 80)
                        .opacity(isLocked(progression: progression) ? 0.6 : 1.0)
                        .onTapGesture {
                            if !isLocked(progression: progression) {
                                exerciseSelected(progression)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(16)
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
        let exerciseTypeLevel = getExerciseTypeLevel(for: progression.exerciseType)
        return exerciseTypeLevel < progression.level
    }
    
    func getMainProgression() -> Progression? {
        let userLevel = getExerciseTypeLevel(for: exercise.exerciseType)
        return exercise.progression
            .filter { $0.level <= userLevel }
            .sorted(by: { $0.level > $1.level })
            .first
    }
    
    func getOtherProgressions() -> [Progression] {
        let mainProgression = getMainProgression()
        return exercise.progression
            .filter { $0 != mainProgression }
            .sorted(by: { $0.level < $1.level })
    }
}

#Preview {
    ExerciseLibraryExerciseWidget(
        exercise: ExerciseLibraryExercise.preview()!,
        userXPData: XPData(
            userID: "user1",
            level: 4,
            xp: 100,
            xpNeeded: 200,
            subLevels: Sublevels(
                lowerBodyCompound: XPAttribute(xp: 50, level: 4, xpNeeded: 100),
                lowerBodyIsolation: XPAttribute(xp: 30, level: 2, xpNeeded: 80),
                upperBodyCompound: XPAttribute(xp: 40, level: 3, xpNeeded: 90),
                upperBodyIsolation: XPAttribute(xp: 20, level: 1, xpNeeded: 70)
            )
        ),
        exerciseSelected: {_ in }
    )
}
