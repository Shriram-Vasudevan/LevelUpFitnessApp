import Foundation
import HealthKit

@MainActor
class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    @Published var todaysSteps: (count: Int, comparison: HealthComparison)?
    @Published var todaysCalories: (count: Int, comparison: HealthComparison)?
    @Published var todaysDistance: (count: Int, comparison: HealthComparison)?
    
    let healthStore = HKHealthStore()
    
    init() {
        requestAuthorization()
    }
    
    private func requestAuthorization() {
        guard let stepsQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount),
              let caloriesQuantityType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned),
              let distanceQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            print("Required types are unavailable")
            return
        }
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKObjectType> = [stepsQuantityType, caloriesQuantityType, distanceQuantityType]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                self.getInitialHealthData()
            } else {
                print("Authorization failed: \(String(describing: error))")
            }
        }
    }
    
    func getInitialHealthData() {
        getTodaysSteps()
        getTodaysCalories()
        getTodaysDistance()
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
                        
                        DispatchQueue.main.sync {
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
                        DispatchQueue.main.sync {
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
                        
                        DispatchQueue.main.sync {
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
}

enum HealthComparison {
    case greater, equal, less
}
