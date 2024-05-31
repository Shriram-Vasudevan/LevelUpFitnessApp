//
//  ProgramWorkoutManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/29/24.
//

import Foundation

class ProgramWorkoutManager {
    func moveToNextExercise(exercises: [Exercise], index: Int) -> Exercise {
        let newExercise = exercises[index]
        return newExercise
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}
