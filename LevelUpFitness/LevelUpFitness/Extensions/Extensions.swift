//
//  Extensions.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/8/24.
//

import Foundation

extension Program {
    func getProgramCompletionPercentage() -> Double {
        let totalDays = program.count
        guard totalDays > 0 else {
            return 0.0
        }
        
        var totalExercises = 0
        var completedExercises = 0
        
        for day in program {
            for exercise in day.exercises {
                totalExercises += 1
                if exercise.completed {
                    completedExercises += 1
                }
            }
        }
        
        guard totalExercises > 0 else {
            return 0.0
        }
        
        return (Double(completedExercises) / Double(totalExercises)) * 100
    }
    
    func getDayCompletionPercentages() -> [DayCompletion] {
        var dayCompletions: [DayCompletion] = []
        for day in program {
            let dayPercentage = day.getDayCompletionPercentage()
            print(dayPercentage)
            dayCompletions.append(DayCompletion(day: day.day, percentage: dayPercentage))
        }
        
        return dayCompletions
    }
    
    func getAverageRestDifferential() -> Double {
        var totalRestDifferential = 0.0
        
        for day in program {
            totalRestDifferential += day.getAverageRestDifferential()
        }
        
        return (totalRestDifferential / Double(program.count) * 100)
    }
}

extension ProgramDay {
    func getAverageRestDifferential() -> Double {
        guard exercises.count > 0 else { return 0.0 }
        
        var totalRestDifferential = 0.0
        var totalDatas = 0
        
        for exercise in exercises {
            for exerciseData in exercise.data {
                let restDifferential = abs(Double(exerciseData.rest) - Double(exercise.rest))
                totalRestDifferential += restDifferential
                totalDatas += 1
            }
        }
        
        return (totalRestDifferential / Double(totalDatas)) * 100
    }
    func getDayCompletionPercentage() -> Double {
        guard exercises.count > 0 else { return 0.0 }
        
        let completed = exercises.filter({ $0.completed })

        return (Double(completed.count) / Double(exercises.count)) * 100
    }
}
