//
//  Extensions.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/8/24.
//

import Foundation
import SwiftUI

extension Array where Element == Program {
    
    private func calculateScaledTrendScore(rawScore: Int, maxScore: Int, minScore: Int) -> Int {
        let targetMin = -5.0
        let targetMax = 10.0
        
        print("the raw score \(rawScore) min score \(minScore) max score \(maxScore)")
        
        let scaleFactor = (targetMax - targetMin) / Double(maxScore - minScore)

        let mappedValue = targetMin + (Double(rawScore) - Double(minScore)) * scaleFactor

        let clampedValue = Swift.min(Swift.max(mappedValue, targetMin), targetMax)

        return Int(round(clampedValue))
    }

    private func filterPrograms() -> [Program] {
        var filteredPrograms = self

        filteredPrograms.removeAll { program in
            program.getProgramCompletionPercentage() < 20
        }
        
        if let mostRecentProgram = filteredPrograms.last, mostRecentProgram.getProgramCompletionPercentage() < 60 {
            filteredPrograms.removeLast()
        }
        
        return filteredPrograms.count >= 2 ? filteredPrograms : []
    }
    
    func getWeightTrendContribution() -> Int {
        let programs = filterPrograms()
        guard programs.count >= 2 else { return 0 }
        
        var totalTrend = 0
        var totalExerciseCount = 0

        var exerciseAverages: [String: [Double]] = [:]

        for program in programs {
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

        var maxTrendValue = 0
        var minTrendValue = 0
        
        for (_, averages) in exerciseAverages {
            guard averages.count > 1 else { continue }
            
            maxTrendValue += 3 * averages.count
            minTrendValue -= 3 * averages.count
            
            var previousAverage = averages.first!
            var exerciseTrend = 0
            
            for currentAverage in averages.dropFirst() {
                if currentAverage > previousAverage {
                    exerciseTrend += 3
                } else if currentAverage < previousAverage {
                    exerciseTrend -= 3
                }
                previousAverage = currentAverage
            }
            
            totalTrend += exerciseTrend
            totalExerciseCount += (averages.count - 1)
        }
        
        guard totalExerciseCount > 0 else { return 0 }
        
        print("weight trned \(totalTrend)")
        print("weight contribution \(calculateScaledTrendScore(rawScore: totalTrend, maxScore: maxTrendValue, minScore: minTrendValue))")
        return calculateScaledTrendScore(rawScore: totalTrend, maxScore: maxTrendValue, minScore: minTrendValue)
    }
    
    func getRestDifferentialTrendContribution() -> Int {
        let programs = filterPrograms()
        guard programs.count >= 2 else { return 0 }
        
        var totalDifferential = 0.0
        var totalExerciseCount = 0
        
        var restDifferentials: [String: [Double]] = [:]
        
        for program in programs {
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
        
        var maxTrendValue = 0
        var minTrendValue = 0
        
        for (_, differentials) in restDifferentials {
            guard differentials.count > 0 else { continue }
            
            let averageDifferential = differentials.reduce(0.0, +) / Double(differentials.count)
            totalDifferential += averageDifferential
            totalExerciseCount += 1
        }
        
        guard totalExerciseCount > 0 else { return 0 }
        
        let maxDifferential = totalExerciseCount * 10
        let minDifferential = totalExerciseCount * 10
        
        print("rest dif contribution \(calculateScaledTrendScore(rawScore: Int(totalDifferential), maxScore: maxDifferential, minScore: minDifferential))")
        
        return calculateScaledTrendScore(rawScore: Int(totalDifferential), maxScore: maxDifferential, minScore: minDifferential)
    }
    
    func getConsistencyTrendContribution() -> Int {
        let programs = filterPrograms()
        guard programs.count >= 2 else { return 0 }
        
        var programCompletionRates: [Double] = []
        
        for program in programs {
            let completionRate = program.getProgramCompletionPercentage()
            programCompletionRates.append(completionRate)
        }
        
        guard programCompletionRates.count > 1 else { return 0 }
        
        var maxTrendValue = 0
        var minTrendValue = 0
        
        maxTrendValue += 4 * programCompletionRates.count
        minTrendValue -= 3 * programCompletionRates.count
        
        var previousRate = programCompletionRates.first!
        var trendScore = 0
    
        print("the program completion rates \(programCompletionRates)")
        for currentRate in programCompletionRates.dropFirst() {
            if currentRate > previousRate {
                trendScore += 4
            } else if currentRate < previousRate {
                trendScore -= 3
            }
            previousRate = currentRate
        }
        
        print("consistency trend score \(trendScore)")
        print("consistency contribution \(calculateScaledTrendScore(rawScore: trendScore, maxScore: maxTrendValue, minScore: minTrendValue))")
        return calculateScaledTrendScore(rawScore: trendScore, maxScore: maxTrendValue, minScore: minTrendValue)
    }
    
    func getRestTimeTrendContribution() -> Int {
        let programs = filterPrograms()
        guard programs.count >= 2 else { return 0 }
        
        var programRestTimeAverages: [Double] = []
        
        for program in programs {
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
        
        var maxTrendValue = 0
        var minTrendValue = 0
        
        maxTrendValue += 3 * programRestTimeAverages.count
        minTrendValue -= 2 * programRestTimeAverages.count
        
        var previousAverage = programRestTimeAverages.first!
        var restTimeTrendScore = 0
        
        for currentAverage in programRestTimeAverages.dropFirst() {
            if currentAverage < previousAverage {
                restTimeTrendScore += 3
            } else if currentAverage > previousAverage {
                restTimeTrendScore -= 2
            }
            previousAverage = currentAverage
        }
        
        print("rest time contribution \(calculateScaledTrendScore(rawScore: restTimeTrendScore, maxScore: maxTrendValue, minScore: minTrendValue))")
        return calculateScaledTrendScore(rawScore: restTimeTrendScore, maxScore: maxTrendValue, minScore: minTrendValue)
    }
}



extension UserChallenge {
    func toDictionary() -> [String: Any] {
        return [
            "userID": userID,
            "id": id,
            "challengeTemplateID": challengeTemplateID,
            "startDate": startDate,
            "endDate": endDate,
            "startValue": startValue,
            "targetValue": targetValue,
            "field": field,
            "isFailed": isFailed,
            "isActive": isActive
        ]
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
        
        print("the average time \(totalTime / Double(program.count))")
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
    
    func getConsecutiveCompletionDays() -> Result<Int, Error> {
        guard let startDate = DateUtility.getDateNWeeksAfterDate(dateString: self.startDate, weeks: 0) else {
            return .failure(NSError(domain: "Invalid start date", code: 0, userInfo: nil))
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        guard let programStartDate = dateFormatter.date(from: startDate) else {
            return .failure(NSError(domain: "Invalid start date format", code: 1, userInfo: nil))
        }
        
        let calendar = Calendar.current
        let currentDate = Date()
        let programStartDay = calendar.startOfDay(for: programStartDate)
        
        guard currentDate >= programStartDay else {
            return .failure(NSError(domain: "Program hasn't started yet", code: 2, userInfo: nil))
        }
        
        var consecutiveDays = 0
        var currentCheckDate = programStartDay
        
        while currentCheckDate <= currentDate {
            let dayOfWeek = calendar.component(.weekday, from: currentCheckDate)
            let weekdayName = dateFormatter.weekdaySymbols[dayOfWeek - 1].lowercased()
            
            if let programDay = program.first(where: { $0.day.lowercased() == weekdayName }) {
                if !programDay.completed {
                    return .failure(NSError(domain: "Incomplete program day", code: 3, userInfo: nil))
                } else {
                    consecutiveDays += 1
                }
            }
            
            currentCheckDate = calendar.date(byAdding: .day, value: 1, to: currentCheckDate)!
        }

        let todayDayOfWeek = calendar.component(.weekday, from: currentDate)
        let todayWeekdayName = dateFormatter.weekdaySymbols[todayDayOfWeek - 1].lowercased()
        
        if let todayProgramDay = program.first(where: { $0.day.lowercased() == todayWeekdayName }), todayProgramDay.completed {
            consecutiveDays += 1
        }
        
        return .success(consecutiveDays)
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

extension ProgramExercise {
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
    func attribute(for key: String) -> XPAttribute? {
            switch key.lowercased() {
                case "lower body compound":
                    return lowerBodyCompound
                case "lower body isolation":
                    return lowerBodyIsolation
                case "upper body compound":
                    return upperBodyCompound
                case "upper body isolation":
                    return upperBodyIsolation
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
    
    func cleanS3ProgramRepresentation() -> String {
        var cleanedInput = self
                .replacingOccurrences(of: "Optional(", with: "")
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
                .replacingOccurrences(of: "\"", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
        if !cleanedInput.contains(")") && cleanedInput.contains("(") {
            cleanedInput.append(")")
        }
        
        return cleanedInput
    }
}

extension FileHandle {
    func readLine() -> String? {
        var lineData = Data()
        while true {
            let data = self.readData(ofLength: 1)
            if data.isEmpty {
                // End of file or error
                return lineData.isEmpty ? nil : String(data: lineData, encoding: .utf8)
            }
            if data == "\n".data(using: .utf8) {
                // End of line
                return String(data: lineData, encoding: .utf8)
            }
            lineData.append(data)
        }
    }
}
