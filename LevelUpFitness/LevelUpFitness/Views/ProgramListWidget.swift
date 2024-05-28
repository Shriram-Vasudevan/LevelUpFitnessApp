//
//  ProgramListWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/27/24.
//

import SwiftUI

struct ProgramListWidget: View {
    @Binding var navigateToProgramView: Bool
    
    var program: Program
    
    var body: some View {
        VStack {
            HStack {
                Text(getCurrentWeekday())
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Image(systemName: "chevron.left")
                Image(systemName: "chevron.right")
            }
            
            Divider()
                .padding(.bottom, 5)
            
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
                        }
                    }
                }
            } else {
                Text("No program for today")
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                navigateToProgramView = true
            }) {
                Text("Let's Go!")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(20)
                    .background(.blue)
                    .cornerRadius(15)
            }
            .padding(.top, 15)
            
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
                .shadow(radius: 5)
        )
        .padding(.horizontal)
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
    ProgramListWidget(navigateToProgramView: .constant(false), program: Program(program: [ProgramDay(day: "", workout: "", completed: false, exercises: [Exercise(name: "", sets: "", reps: "", rpe: "", rest: 0, completed: false)])]))
}
