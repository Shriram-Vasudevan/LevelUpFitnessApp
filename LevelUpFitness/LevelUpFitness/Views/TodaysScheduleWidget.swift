//
//  TodaysScheduleWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/2/24.
//

import SwiftUI

import SwiftUI

struct TodaysScheduleWidget: View {
    @ObservedObject var programManager: ProgramManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Schedule")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            if let todaysProgram = programManager.program?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                ForEach(todaysProgram.exercises.prefix(3), id: \.name) { exercise in
                    ExerciseRow(exercise: exercise)
                }
                
                if todaysProgram.exercises.count > 3 {
                    Text("+ \(todaysProgram.exercises.count - 3) more exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("No exercises scheduled for today")
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
    }

}

struct ExerciseRow: View {
    let exercise: ProgramExercise
    
    var body: some View {
        HStack {
            Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.walk")
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text("\(exercise.sets) sets • \(exercise.reps) reps • RPE \(exercise.rpe)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: exercise.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(exercise.completed ? .green : .secondary)
        }
    }
}
#Preview {
    TodaysScheduleWidget(programManager: ProgramManager())
}
