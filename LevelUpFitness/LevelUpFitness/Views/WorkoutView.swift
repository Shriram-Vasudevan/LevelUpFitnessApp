//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

struct WorkoutView: View {
    @State var program: Program
    @State var currentExercise: Exercise?
    
    var body: some View {
        ZStack {
            if let currentExercise = currentExercise {
                VStack {
                    HStack {
                        VStack (alignment: .leading, spacing: 0) {
                            Text(currentExercise.name)
                                .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                .padding(.bottom, -7)
                            
                            HStack {
                                Text("Reps: \(currentExercise.reps)")
                                Text("Sets: \(currentExercise.sets)")
                                
                                Spacer()
                            }
                        }
                        
                        Spacer()
                        
                        Text("Complete")
                            .font(.footnote)
                            .bold()
                            .padding()
                            .background(
                                Capsule()
                                    .fill(.green)
                            )
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.top, 50)

                    
                    Image("GuyAtTheGym")
                        .resizable()
                        .frame(height:  200)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    HStack {
                        Text("Visual Demonstration")
                            .bold()
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            
        }
    }
    
    func moveToNextExercise() {
        
    }
}

#Preview {
    WorkoutView(program: Program(program: [ProgramDay(day: "", workout: "", completed: false, exercises: [Exercise(name: "", sets: "", reps: "", rpe: "", rest: 0, completed: false)])]), currentExercise: Exercise(name: "", sets: "", reps: "", rpe: "", rest: 0, completed: false))
}
