//
//  CustomWorkout.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/16/24.
//

import Foundation

struct CustomWorkout: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var image: Data?
    var exercises: [CustomWorkoutExercise]
}

struct CustomWorkoutExercise: Codable {
    var name: String
    var isWeight: Bool
}
