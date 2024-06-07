//
//  ExerciseDataWidgetModel.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/4/24.
//

import Foundation

struct ExerciseDataWidgetModel: Codable, Equatable {
    var weight: Int
    var time: Double
    var rest: Double
    var isAvailable: Bool
    var isStarted: Bool
    var stopRestTimer: Bool
}
