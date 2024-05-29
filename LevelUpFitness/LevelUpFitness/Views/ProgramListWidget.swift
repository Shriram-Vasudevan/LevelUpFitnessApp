//
//  ProgramListWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/27/24.
//

import SwiftUI

struct ProgramListWidget: View {
    @Binding var navigateToWorkoutView: Bool
    
    var program: Program
    
    var body: some View {
        VStack {
            HStack {
                Text(getCurrentWeekday())
                    .font(.title)
                    .bold()
                
                Spacer()
                
            }
            
            Divider()
                .padding(.bottom, 5)
            
            ZStack {
                Image("ManExercising - PushUp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                if let todayProgram = program.program.first(where: { $0.day == getCurrentWeekday() }) {
                    VStack(spacing: 5) {
                        ForEach(todayProgram.exercises, id: \.name) { exercise in
                            HStack {
                                Text("\(exercise.name)")
                                
                                Spacer()
                                
                                if exercise.completed {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                else {
                                    Button {
                                        navigateToWorkoutView = true
                                    } label: {
                                        Text("Start Now")
                                    }

                                }
                            }
                        }
                    }
                } else {
                    Text("No program for today")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(.white)
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}

#Preview {
    ProgramListWidget(navigateToWorkoutView: .constant(false), program: Program(program: [ProgramDay(day: "", workout: "", completed: false, exercises: [Exercise(name: "", sets: "", reps: "", rpe: "", rest: 0, completed: false)])]))
}
