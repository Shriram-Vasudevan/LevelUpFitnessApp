//
//  CustomWorkoutWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/17/24.
//

import SwiftUI

struct CustomWorkoutWidget: View {
    let workout: CustomWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = workout.image, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipped()
                    .cornerRadius(10)
            } else {
                Image("NoImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 150, height: 100)
                    .clipped()
                    .cornerRadius(10)
            }
            
            VStack (spacing: 4) {
                Text(workout.name)
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(.black)
                
                Text("\(workout.exercises.count) exercises")
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 150)
        .padding(12)
        .background(Color(hex: "F5F5F5"))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    CustomWorkoutWidget(workout: CustomWorkout(name: "", image: nil, exercises: [CustomWorkoutExercise(name: "", isWeight: true)]))
}
