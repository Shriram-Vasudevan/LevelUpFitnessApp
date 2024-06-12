//
//  LibraryView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct LibraryView: View {
    @State var exercises: [WorkoutLibraryExercise] = [WorkoutLibraryExercise(name: "Lunge", image: ""), WorkoutLibraryExercise(name: "Russian Twist", image: ""), WorkoutLibraryExercise(name: "Deadlift", image: ""), WorkoutLibraryExercise(name: "Situp", image: ""), WorkoutLibraryExercise(name: "Pushup", image: ""), WorkoutLibraryExercise(name: "Pullup", image: ""), WorkoutLibraryExercise(name: "Plank", image: ""), WorkoutLibraryExercise(name: "Squat", image: ""), WorkoutLibraryExercise(name: "Benchpress", image: "")]
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack (spacing: 0) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 15)
                        .hidden()
                    
                    Spacer()
                    
                    Text("Workout Library")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 15)
                }
                .padding(.horizontal)
                
                VStack {
                    ScrollView(.vertical) {
                        ForEach(exercises, id: \.self) { exercise in
                            WorkoutLibraryExerciseWidget(workoutLibraryExercise: exercise)
                        }
                        
                        HStack {
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .padding(.top)
                .background(
                    Rectangle()
                        .fill(.white)
                )
                .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    LibraryView()
}
