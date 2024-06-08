//
//  HealthManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/7/24.
//

import Foundation
import HealthKit

class HealthManager: ObservableObject {
    @Published var todaysSteps: Double?
    
    let healthStore = HKHealthStore()
    
    func getInitialHealthData() {
        getTodaysSteps()
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
        
        let query = HKStatisticsQuery(
            quantityType: stepsQuantityType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else {
                print("failed")
                return
            }
            
            self.todaysSteps = sum.doubleValue(for: HKUnit.count())
            print(self.todaysSteps)
        }
        
        healthStore.execute(query)
    }
}
