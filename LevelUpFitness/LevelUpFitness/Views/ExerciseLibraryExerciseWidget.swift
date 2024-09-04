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
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let progression = getMainProgression() {
                mainProgressionView(progression: progression)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Other Progressions")
                        .font(.headline)
                        .foregroundColor(Color(hex: "1E293B"))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(getOtherProgressions(), id: \.self) { progression in
                                VStack(spacing: 8) {
                                    ZStack {
                                        Image("GuyAtTheGym")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .overlay (isLocked(progression: progression) ?
                                                RoundedRectangle(cornerRadius: 8)
                                                .background(
                                                    Color.black.opacity(0.6)
                                                )
                                                .overlay {
                                                    Image(systemName: "lock.fill")
                                                        .foregroundColor(.white)
                                                } : nil
                                            )
                                    }
                                    
                                    Text(progression.name)
                                        .font(.caption)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Level \(progression.level)")
                                        .font(.caption2)
                                        .foregroundColor(Color(hex: "3B82F6"))
                                    
                                    Button(action: {
                                        if !isLocked(progression: progression) {
                                            exerciseSelected(progression)
                                        }
                                    }) {
                                        Text(isLocked(progression: progression) ? "Locked" : "Start")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(isLocked(progression: progression) ? Color.gray : Color(hex: "3B82F6"))
                                            .cornerRadius(12)
                                    }
                                    .disabled(isLocked(progression: progression))
                                }
                                .frame(width: 100)
                                .padding(8)
                                .background(Color(hex: "F8FAFC"))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func mainProgressionView(progression: Progression) -> some View {
        HStack(spacing: 16) {
            Image("GuyAtTheGym")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(progression.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "1E293B"))
                Text("Level \(progression.level)")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "3B82F6"))
                Text(exercise.exerciseType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack {
                Button(action: {
                    exerciseSelected(progression)
                }) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(Color(hex: "3B82F6"))
                        .font(.system(size: 30))
                }
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 24))
                }
            }
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
