//
//  CustomWorkoutWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/17/24.
//

import SwiftUI

struct CustomWorkoutWidget: View {
    let workout: CustomWorkout
    let onDelete: (CustomWorkout) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = workout.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipped()
                    .cornerRadius(2)
            } else {
                Image("NoImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipped()
                    .cornerRadius(2)
            }
            
            HStack {
                VStack (spacing: 4) {
                    HStack {
                        Text(workout.name)
                            .font(AppTheme.Typography.telemetry(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.textPrimary)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("\(workout.exercises.count) exercises")
                            .font(AppTheme.Typography.telemetry(size: 14))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                        
                        Spacer()
                    }

                }
                
                Spacer()
                
                Button(action: {
                    onDelete(workout)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                        .padding(6)
                }
            }
        }
        .frame(width: 150)
        .padding(12)
        .engineeredPanel(isElevated: true)
    }
}

