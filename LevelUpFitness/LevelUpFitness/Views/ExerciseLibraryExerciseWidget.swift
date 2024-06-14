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
        VStack (spacing: 10) {
            HStack {
                Image("GuyAtTheGym")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .frame(height: 60)
                    
                
                Spacer()
                
                Text(exerciseLibraryExercise.name)
                    .font(.custom("Sailec Bold", size: 20))
            }
            .padding(.horizontal)
            
            Divider()
        }
    }
}

#Preview {
    ExerciseLibraryExerciseWidget(exerciseLibraryExercise: ExerciseLibraryExerciseDownloaded(name: "Push-up", videoURL: URL(string: "Test")!))
}
