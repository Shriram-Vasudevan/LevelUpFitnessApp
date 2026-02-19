import Foundation
import HealthKit
import SwiftUI

@MainActor
class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    @Published var todaysSteps: (count: Int, comparison: HealthComparison)?
    @Published var todaysCalories: (count: Int, comparison: HealthComparison)?
    @Published var todaysDistance: (count: Int, comparison: HealthComparison)?
    
    let healthStore = HKHealthStore()
    
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let caloriesQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print("Required types are unavailable")
            completion(false)
            return
        }
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [stepsQuantityType, caloriesQuantityType, distanceQuantityType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            Task { @MainActor in
                if success {
                    completion(true)
                } else {
                    print("Authorization failed: \(String(describing: error))")
                    completion(false)
                }
            }
        }
    }
    
    func getInitialHealthData() {
        requestAuthorization { [weak self] success in
            guard success, let self else { return }
            self.getTodaysSteps()
            self.getTodaysCalories()
            self.getTodaysDistance()
        }
    }
        
    func getTodaysSteps() {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsCollectionQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                print("Failed to get steps: \(String(describing: error))")
                return
            }
            
            results.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let todaysSteps = Int(sum.doubleValue(for: .count()))
                    
                    self.getYesterdaysSteps { yesterdaysSteps in
                        let comparison: HealthComparison
                        if todaysSteps > yesterdaysSteps {
                            comparison = .greater
                        } else if todaysSteps < yesterdaysSteps {
                            comparison = .less
                        } else {
                            comparison = .equal
                        }
                        
                        DispatchQueue.main.async {
                            self.todaysSteps = (count: todaysSteps, comparison: comparison)
                        }
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func getYesterdaysSteps(completion: @escaping (Int) -> Void) {
        let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let now = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterday,
            end: endOfYesterday,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let steps = Int(sum.doubleValue(for: .count()))
            completion(steps)
        }
        
        healthStore.execute(query)
    }
    
    func getTodaysCalories() {
        let caloriesQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsCollectionQuery(
            quantityType: caloriesQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                print("Failed to get calories: \(String(describing: error))")
                return
            }
            
            results.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let todaysCalories = Int(sum.doubleValue(for: .kilocalorie()))
                    
                    self.getYesterdaysCalories { yesterdaysCalories in
                        let comparison: HealthComparison
                        if todaysCalories > yesterdaysCalories {
                            comparison = .greater
                        } else if todaysCalories < yesterdaysCalories {
                            comparison = .less
                        } else {
                            comparison = .equal
                        }
                        DispatchQueue.main.async {
                            self.todaysCalories = (count: todaysCalories, comparison: comparison)
                        }
                        
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func getYesterdaysCalories(completion: @escaping (Int) -> Void) {
        let caloriesQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let now = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterday,
            end: endOfYesterday,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: caloriesQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let calories = Int(sum.doubleValue(for: .kilocalorie()))
            completion(calories)
        }
        
        healthStore.execute(query)
    }
    
    func getTodaysDistance() {
        let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        let query = HKStatisticsCollectionQuery(
            quantityType: distanceQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: startOfDay,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { query, results, error in
            guard let results = results else {
                print("Failed to get distance: \(String(describing: error))")
                return
            }
            
            results.enumerateStatistics(from: startOfDay, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let todaysDistance = sum.doubleValue(for: .meter())
                    
                    self.getYesterdaysDistance { yesterdaysDistance in
                        let comparison: HealthComparison
                        if todaysDistance > yesterdaysDistance {
                            comparison = .greater
                        } else if todaysDistance < yesterdaysDistance {
                            comparison = .less
                        } else {
                            comparison = .equal
                        }
                        
                        DispatchQueue.main.async {
                            self.todaysDistance = (count: Int(todaysDistance), comparison: comparison)
                        }
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func getYesterdaysDistance(completion: @escaping (Double) -> Void) {
        let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let now = Date()
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        let endOfYesterday = calendar.date(byAdding: .day, value: 1, to: startOfYesterday)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfYesterday,
            end: endOfYesterday,
            options: .strictStartDate
        )
        
        let query = HKStatisticsQuery(
            quantityType: distanceQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            
            let distance = sum.doubleValue(for: .meter())
            completion(distance)
        }
        
        healthStore.execute(query)
    }
    
    func fetchAverageSteps(forLastNDays days: Int, completion: @escaping (Double) -> Void) {
        fetchHistoricalData(forLastNDays: days, quantityType: .stepCount) { dataPoints in
            let totalSteps = dataPoints.reduce(0.0) { $0 + $1.value }
            let averageSteps = totalSteps / Double(days)
            completion(averageSteps)
        }
    }

    func fetchHistoricalData(forLastNDays days: Int, quantityType identifier: HKQuantityTypeIdentifier, completion: @escaping ([HealthDataPoint]) -> Void) {
        guard let quantityType = HKQuantityType.quantityType(forIdentifier: identifier) else {
            completion([])
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: now)!
        let anchorDate = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: quantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: DateComponents(day: 1)
        )
        
        query.initialResultsHandler = { _, results, error in
            var dataPoints: [HealthDataPoint] = []
            
            guard let results = results else {
                print("Failed to fetch historical data: \(String(describing: error))")
                completion(dataPoints)
                return
            }
            
            results.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    var value: Double
                
                    if identifier == .stepCount {
                        value = sum.doubleValue(for: .count())
                    } else if identifier == .distanceWalkingRunning {
                        value = sum.doubleValue(for: .meter()) / 1000.0
                    } else if identifier == .activeEnergyBurned {
                        value = sum.doubleValue(for: .kilocalorie())
                    } else {
                        value = 0
                    }
                    
                    let date = statistics.startDate
                    dataPoints.append(HealthDataPoint(date: date, value: value))
                }
            }
            
            completion(dataPoints)
        }
        
        healthStore.execute(query)
    }
}

enum HealthComparison {
    case greater, equal, less
}
