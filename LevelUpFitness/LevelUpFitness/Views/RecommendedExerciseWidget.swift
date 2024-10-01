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
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(exercise.exerciseType)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "40C4FC"))
            }

            HStack {
                Spacer()
                Text("Recommended Exercise")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }

            Button(action: {
                exerciseSelected()
            }) {
                Text("Let's Go")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
            }
        }
        .padding(16)
        .background(Color(hex: "F9F9F9"))
        .cornerRadius(8)
    }
}



#Preview {
    RecommendedExerciseWidget(exercise: Progression.preview()!, exerciseSelected: {})
}
