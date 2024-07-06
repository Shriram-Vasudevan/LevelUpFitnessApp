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
            for set in exercise.data.sets {
                totalTime += set.time
            }
        }
        
        return totalTime
    }
    
    func getTotalRestTime() -> Double {
        var totalRestTime = 0.0
        
        for exercise in exercises {
            for set in exercise.data.sets {
                totalRestTime += set.rest
            }
        }
        
        return totalRestTime
    }
    
    func getTotalWeightUsed() -> Int {
        var totalWeight = 0
        
        for exercise in exercises {
            for set in exercise.data.sets {
                totalWeight += set.weight
            }
        }
        
        return totalWeight
    }
    
}

extension Exercise {
    func getAverageRestDifferential() -> Double {
        guard data.sets.count > 0 else { return 0.0 }
        
        var totalRestDifferential = 0.0
        
        for set in data.sets {
            let restDifferential = abs(Double(set.rest) - Double(rest))
            totalRestDifferential += restDifferential
        }
        
        return totalRestDifferential / Double(data.sets.count)
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
