//
//  RecommendedExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI

struct RecommendedExerciseWidget: View {
    var exercise: Progression
    var exerciseSelected: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 20, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    Text(exercise.exerciseType)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
            
            Button(action: {
                exerciseSelected()
            }) {
                Text("Let's Go")
                    .font(.system(size: 14, weight: .semibold, design: .default))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
            }
            
            HStack {
                Spacer()
                Text("Recommended Exercise")
                    .font(.system(size: 12, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
        }
        .padding(20)
        .background(Color(hex: "F5F5F5"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "40C4FC"))
                .frame(width: 4)
                .padding(.vertical, 20),
            alignment: .leading
        )
    }
}

#Preview {
    RecommendedExerciseWidget(exercise: Progression.preview()!, exerciseSelected: {})
}
