//
//  RecommendedExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI

struct RecommendedExerciseWidget: View {
    var exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(exercise.area)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button(action: {
                // Action to view exercise details
            }) {
                Text("Let's Go")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            HStack {
                Spacer()
                
                Text("Recommended Exercise")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.top, -20)
        }
        .padding([.horizontal, .top], 20)
        .padding(.bottom, 5)
        .background(
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.2, blue: 0.7),
                Color(red: 0.2, green: 0.3, blue: 0.8)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding()
    }
}

#Preview {
    RecommendedExerciseWidget(exercise: Exercise(name: "Pull-ups", sets: 5, reps: 5, rpe: "", rest: 5, area: "Back", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 5, reps: 5, time: 5.0, rest: 5.0)])))
}
