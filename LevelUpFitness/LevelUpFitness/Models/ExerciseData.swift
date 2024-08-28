//
//  ExerciseData.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/28/24.
//

import Foundation

struct ExerciseData: Codable, Hashable {
    var sets: [ExerciseDataSet]
}

struct ExerciseDataSet: Codable, Hashable {
    var weight: Int
    var reps: Int
    var time: Double
    var rest: Double
}
