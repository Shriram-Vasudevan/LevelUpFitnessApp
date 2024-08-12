//
//  Extensions.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/8/24.
//

import Foundation
import SwiftUI

extension Array where Element == Program {
    
    private func calculateScaledTrendScore(rawScore: Int, maxScore: Int) -> Int {
        guard maxScore != 0 else { return 0 } 
        let scaleFactor = Double(10) / Double(maxScore)
        let scaledScore = Double(rawScore) * scaleFactor
        return Swift.max(-10, Swift.min(10, Int(scaledScore)))
    }

    func getWeightTrendContribution() -> Int {
        var totalTrend = 0
        var totalExerciseCount = 0

        var exerciseAverages: [String: [Double]] = [:]

        for program in self {
            for day in program.program {
                for exercise in day.exercises {
                    let exerciseName = exercise.name
                    let totalWeight = exercise.data.sets.reduce(0) { $0 + $1.weight }
                    let averageWeight = Double(totalWeight) / Double(exercise.data.sets.count)
                    
                    if exerciseAverages[exerciseName] == nil {
                        exerciseAverages[exerciseName] = []
                    }
                    exerciseAverages[exerciseName]?.append(averageWeight)
                }
            }
        }

        for (_, averages) in exerciseAverages {
            guard averages.count > 1 else { continue }
            
            var previousAverage = averages.first!
            var exerciseTrend = 0
            
            for currentAverage in averages.dropFirst() {
                if currentAverage > previousAverage {
                    exerciseTrend += 1
                } else if currentAverage < previousAverage {
                    exerciseTrend -= 1
                }
                previousAverage = currentAverage
            }
            
            totalTrend += exerciseTrend
            totalExerciseCount += (averages.count - 1)
        }
        
        guard totalExerciseCount > 0 else { return 0 }

        let maxTrendValue = totalExerciseCount * 2
        return calculateScaledTrendScore(rawScore: totalTrend, maxScore: maxTrendValue)
    }
    
    func getRestDifferentialTrendContribution() -> Int {
        var totalDifferential = 0
        var totalExerciseCount = 0
        
        var restDifferentials: [String: [Double]] = [:]
        
        for program in self {
            for day in program.program {
                for exercise in day.exercises {
                    let exerciseName = exercise.name
                    let prescribedRest = Double(exercise.rest)
                    let actualRestAverage = exercise.data.sets.reduce(0.0) { $0 + $1.rest } / Double(exercise.data.sets.count)
                    
                    let differential = abs(prescribedRest - actualRestAverage)
                    
                    if restDifferentials[exerciseName] == nil {
                        restDifferentials[exerciseName] = []
                    }
                    restDifferentials[exerciseName]?.append(differential)
                }
            }
        }
        
        for (_, differentials) in restDifferentials {
            guard differentials.count > 0 else { continue }
            
            let averageDifferential = differentials.reduce(0.0, +) / Double(differentials.count)
            totalDifferential += Int(averageDifferential)
            totalExerciseCount += 1
        }
        
        guard totalExerciseCount > 0 else { return 0 }
        
        let maxDifferential = totalExerciseCount * 10
        return calculateScaledTrendScore(rawScore: -totalDifferential, maxScore: maxDifferential)
    }
    
    func getConsistencyTrendContribution() -> Int {
        var programCompletionRates: [Double] = []
        
        for program in self {
            let totalDays = program.program.count
            let completedDays = program.program.filter { $0.completed }.count
            
            guard totalDays > 0 else { continue }
            
            let completionRate = Double(completedDays) / Double(totalDays)
            programCompletionRates.append(completionRate)
        }
        
        guard programCompletionRates.count > 1 else { return 0 }
        
        var previousRate = programCompletionRates.first!
        var trendScore = 0
        
        for currentRate in programCompletionRates.dropFirst() {
            if currentRate > previousRate {
                trendScore += 1
            } else if currentRate < previousRate {
                trendScore -= 1
            }
            previousRate = currentRate
        }
        
        let maxTrendValue = (programCompletionRates.count - 1) * 2
        return calculateScaledTrendScore(rawScore: trendScore, maxScore: maxTrendValue)
    }
    
    func getRestTimeTrendContribution() -> Int {
        var programRestTimeAverages: [Double] = []
        
        for program in self {
            var totalRestTime = 0.0
            var totalSets = 0
            
            for day in program.program {
                for exercise in day.exercises {
                    let totalRestForExercise = exercise.data.sets.reduce(0.0) { $0 + $1.rest }
                    totalRestTime += totalRestForExercise
                    totalSets += exercise.data.sets.count
                }
            }
            
            guard totalSets > 0 else { continue }
            
            let averageRestTime = totalRestTime / Double(totalSets)
            programRestTimeAverages.append(averageRestTime)
        }
        
        guard programRestTimeAverages.count > 1 else { return 0 }
        
        var previousAverage = programRestTimeAverages.first!
        var restTimeTrendScore = 0
        
        for currentAverage in programRestTimeAverages.dropFirst() {
            if currentAverage < previousAverage {
                restTimeTrendScore += 1
            } else if currentAverage > previousAverage {
                restTimeTrendScore -= 1
            }
            previousAverage = currentAverage
        }
        
        let maxTrendValue = (programRestTimeAverages.count - 1) * 2
        return calculateScaledTrendScore(rawScore: restTimeTrendScore, maxScore: maxTrendValue)
    }
}


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
    
    func getAverageWorkoutTime() -> Double {
        var totalTime = 0.0
        
        for day in program {
            totalTime += day.getTotalWorkoutTime()
        }
        
        return totalTime / Double(program.count)
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
    
    func getMostFrequentMuscleGroups() -> [MuscleGroupStat] {
        var muscleGroupCounts: [String: Int] = [:]
        
        for day in program {
            for exercise in day.exercises {
                muscleGroupCounts[exercise.area, default: 0] += 1
            }
        }
        
        let sortedMuscleGroups = muscleGroupCounts.sorted { $0.value > $1.value }
        return sortedMuscleGroups.map { MuscleGroupStat(area: $0.key, count: $0.value) }
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
                totalWeight += set.weight * set.reps
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

extension Sublevels {
    func getAverage() -> Int {
        return Int((mobility.level + strength.level + endurance.level) / 3)
    }
    
    func attribute(for key: String) -> XPAttribute? {
        switch key.lowercased() {
            case "strength":
                return strength
            case "endurance":
                return endurance
            case "mobility":
                return mobility
            default:
                return nil
            }
    }
}

extension BodyAreas {
    func attribute(for key: String) -> XPAttribute? {
            switch key.lowercased() {
                case "back":
                    return back
                case "legs":
                    return legs
                case "chest":
                    return chest
                case "shoulders":
                    return shoulders
                case "core":
                    return core
                default:
                    return nil
            }
    }
}

extension XPAttribute {
    mutating func incrementXP(increment: Int) {
        xp += increment
        if xp > xpNeeded {
            level += 1
            xpNeeded +=  level * 20
        }
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

extension CGPoint: VectorArithmetic {
    public mutating func scale(by rhs: Double) {
        self.x *= CGFloat(rhs)
        self.y *= CGFloat(rhs)
    }

    public var magnitudeSquared: Double {
        return Double(x * x + y * y)
    }

    public static var zero: CGPoint {
        return CGPoint(x: 0, y: 0)
    }

    public static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    public static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

