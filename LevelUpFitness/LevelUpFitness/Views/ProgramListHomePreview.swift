//
//  ProgramListHomePreview.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/1/24.
//

import SwiftUI

struct ProgramListHomePreview: View {
    var todaysProgram: ProgramDay
    var body: some View {
        VStack {            
            Divider()
                .padding(.bottom, 5)
            
            ZStack {
                VStack(spacing: 5) {
                    ScrollView(.vertical) {
                        ForEach(todaysProgram.exercises, id: \.name) { exercise in
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
                }
            }
        }
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
    ProgramListHomePreview(todaysProgram: ProgramDay(day: "Monday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, completed: false, data: [ExerciseData(from: ExerciseDataWidgetModel(weight: 2, reps: 1, time: 8.0, rest: 5.0, isAvailable: false, isStarted: false, isResting: false, stopRestTimer: false, clear: false, isLast: false))])]))
}
