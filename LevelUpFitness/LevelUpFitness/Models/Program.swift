//
//  Program.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/27/24.
//

import Foundation

struct Program: Codable {
    var program: [ProgramDay]
    
    enum CodingKeys: String, CodingKey {
        case program = "workout_schedule"
    }
}
struct ProgramDay: Codable {
    var day: String
    var workout: String
    var completed: Bool
    var exercises: [Exercise]
}

struct Exercise: Codable {
    var name: String
    var sets: Int
    var reps: String
    var rpe: String
    var rest: Int
    var completed: Bool
    var data: [ExerciseData]
}

struct ExerciseData: Codable {
    var weight: Int
    var time: Double
    var rest: Double
}
