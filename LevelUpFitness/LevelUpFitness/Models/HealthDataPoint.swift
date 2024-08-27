//
//  HealthDataPoint.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/26/24.
//

import Foundation

struct HealthDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
