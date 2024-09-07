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
                       .font(.system(size: 18, weight: .medium, design: .default))
                       .foregroundColor(.black)
                   
                   ScrollView(.horizontal, showsIndicators: false) {
                       HStack(spacing: 16) {
                           ForEach(getOtherProgressions(), id: \.self) { progression in
                               otherProgressionView(progression: progression)
                           }
                       }
                   }
               }
           }
       }
       .padding()
       .background(Color.white)
       .cornerRadius(4)
       .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
   }
   
   private func mainProgressionView(progression: Progression) -> some View {
       HStack(spacing: 16) {
           Image("GuyAtTheGym")
               .resizable()
               .aspectRatio(contentMode: .fill)
               .frame(width: 80, height: 80)
               .clipped()
           
           VStack(alignment: .leading, spacing: 4) {
               Text(progression.name)
                   .font(.system(size: 18, weight: .medium, design: .default))
                   .foregroundColor(.black)
               Text("Level \(progression.level)")
                   .font(.system(size: 14, weight: .regular, design: .default))
                   .foregroundColor(Color(hex: "40C4FC"))
               Text(exercise.exerciseType)
                   .font(.system(size: 14, weight: .regular, design: .default))
                   .foregroundColor(.gray)
           }
           
           Spacer()
           
           VStack(spacing: 8) {
               Button(action: {
                   exerciseSelected(progression)
               }) {
                   Image(systemName: "play.fill")
                       .foregroundColor(.white)
                       .frame(width: 40, height: 40)
                       .background(Color(hex: "40C4FC"))
               }
               
               Button(action: {
                   withAnimation {
                       isExpanded.toggle()
                   }
               }) {
                   Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                       .foregroundColor(.gray)
                       .frame(width: 40, height: 40)
                       .background(Color(hex: "F5F5F5"))
               }
           }
       }
   }
   
   private func otherProgressionView(progression: Progression) -> some View {
       VStack(spacing: 8) {
           ZStack {
               Image("GuyAtTheGym")
                   .resizable()
                   .aspectRatio(contentMode: .fill)
                   .frame(width: 80, height: 80)
                   .clipped()
                   .overlay(isLocked(progression: progression) ?
                       Color.black.opacity(0.6)
                           .overlay(
                               Image(systemName: "lock.fill")
                                   .foregroundColor(.white)
                           ) : nil
                   )
           }
           
           Text(progression.name)
               .font(.system(size: 14, weight: .medium, design: .default))
               .lineLimit(2)
               .multilineTextAlignment(.center)
           
           Text("Level \(progression.level)")
               .font(.system(size: 12, weight: .regular, design: .default))
               .foregroundColor(Color(hex: "40C4FC"))
           
           Button(action: {
               if !isLocked(progression: progression) {
                   exerciseSelected(progression)
               }
           }) {
               Text(isLocked(progression: progression) ? "Locked" : "Start")
                   .font(.system(size: 14, weight: .medium, design: .default))
                   .foregroundColor(.white)
                   .padding(.horizontal, 12)
                   .padding(.vertical, 6)
                   .frame(width: 80)
                   .background(isLocked(progression: progression) ? Color.gray : Color(hex: "40C4FC"))
           }
           .disabled(isLocked(progression: progression))
       }
       .frame(width: 100)
       .padding(8)
       .background(Color(hex: "F5F5F5"))
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
