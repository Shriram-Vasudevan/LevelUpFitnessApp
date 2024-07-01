//
//  Extensions.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/8/24.
//

import Foundation
import SwiftUI

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
        var totalExercises = 0
        
        for day in program {
            for exercise in day.exercises {
                let exerciseRestDifferential = exercise.getAverageRestDifferential()
                totalRestDifferential += exerciseRestDifferential
                totalExercises += 1
            }
        }
        
        guard totalExercises > 0 else {
            return 0.0
        }
        
        return totalRestDifferential / Double(totalExercises)
    }
    
    func getTotalWorkoutTime() -> Double {
        var totalTime = 0.0
        
        for day in program {
            totalTime += day.getTotalWorkoutTime()
        }
        
        return totalTime
    }

    func getTotalRestTime() -> Double {
        var totalRestTime = 0.0
        
        for day in program {
            totalRestTime += day.getTotalRestTime()
        }
        
        return totalRestTime
    }
    
    func getTotalWeightUsed() -> Int {
        var totalWeight = 0
        
        for day in program {
            totalWeight += day.getTotalWeightUsed()
        }
        
        return totalWeight
    }
}

extension ProgramDay {
    func getAverageRestDifferential() -> Double {
        var totalRestDifferential = 0.0
        var totalExercises = 0
        
        for exercise in exercises {
            let exerciseRestDifferential = exercise.getAverageRestDifferential()
            totalRestDifferential += exerciseRestDifferential
            totalExercises += 1
        }
        
        guard totalExercises > 0 else {
            return 0.0
        }
        
        return totalRestDifferential / Double(totalExercises)
    }
    
    func getDayCompletionPercentage() -> Double {
        guard exercises.count > 0 else { return 0.0 }
        
        let completed = exercises.filter({ $0.completed })

        return (Double(completed.count) / Double(exercises.count)) * 100
    }
    
    func getTotalWorkoutTime() -> Double {
        var totalTime = 0.0
        
        for exercise in exercises {
            for data in exercise.data {
                totalTime += data.time
            }
        }
        
        return totalTime
    }
    
    func getTotalRestTime() -> Double {
        var totalRestTime = 0.0
        
        for exercise in exercises {
            for data in exercise.data {
                totalRestTime += data.rest
            }
        }
        
        return totalRestTime
    }
    
    func getTotalWeightUsed() -> Int {
        var totalWeight = 0
        
        for exercise in exercises {
            for data in exercise.data {
                totalWeight += data.weight
            }
        }
        
        return totalWeight
    }
    
}

extension Exercise {
    func getAverageRestDifferential() -> Double {
        guard data.count > 0 else { return 0.0 }
        
        var totalRestDifferential = 0.0
        var totalDataPoints = 0
        
        for exerciseData in data {
            let restDifferential = abs(Double(exerciseData.rest) - Double(rest))
            totalRestDifferential += restDifferential
            totalDataPoints += 1
        }
        
        guard totalDataPoints > 0 else {
            return 0.0
        }
        
        return totalRestDifferential / Double(totalDataPoints)
    }
}


extension View {
    func doneButtonToolbar(isFirstResponder: Binding<Bool>) -> some View {
        self.modifier(DoneButtonToolbar(isFirstResponder: isFirstResponder))
    }
    
    func getSizeOfView(_ getSize: @escaping ((CGSize) -> Void)) -> some View {
        return self
            .background {
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: SizePreferenceKey.self,
                        value: geometry.size
                    )
                    .onPreferenceChange(SizePreferenceKey.self) { value in
                        getSize(value)
                    }
                }
            }
    }
}
