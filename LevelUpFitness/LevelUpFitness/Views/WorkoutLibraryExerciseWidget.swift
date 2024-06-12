//
//  WorkoutLibraryExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct WorkoutLibraryExerciseWidget: View {
    var workoutLibraryExercise: WorkoutLibraryExercise
    
    var body: some View {
        VStack (spacing: 10) {
            HStack {
                Image("GuyAtTheGym")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .frame(height: 60)
                    
                
                Spacer()
                
                Text(workoutLibraryExercise.name)
                    .font(.custom("Sailec Bold", size: 20))
            }
            .padding(.horizontal)
            
            Divider()
        }
    }
}

#Preview {
    WorkoutLibraryExerciseWidget(workoutLibraryExercise: WorkoutLibraryExercise(name: "Lunges", image: ""))
}
