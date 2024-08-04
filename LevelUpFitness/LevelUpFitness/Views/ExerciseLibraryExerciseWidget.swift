//
//  ExerciseLibraryExerciseWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct ExerciseLibraryExerciseWidget: View {
    var exerciseLibraryExercise: ExerciseLibraryExerciseDownloaded
    
    var body: some View {
        HStack {
            Image("GuyAtTheGym")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipped()
                .cornerRadius(5)
                
            VStack (alignment: .leading, spacing: 5) {
                Text(exerciseLibraryExercise.name)
                    .font(.headline)
                
                Text(exerciseLibraryExercise.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .frame(height: 60)
            
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ExerciseLibraryExerciseWidget(exerciseLibraryExercise: ExerciseLibraryExerciseDownloaded(id: "Test", name: "Push-up", videoURL: URL(string: "Test")!, description: "Develops upper body and back muscles · Advanced", bodyArea: ""))
}
