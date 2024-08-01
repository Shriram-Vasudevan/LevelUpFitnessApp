//
//  Program.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/27/24.
//

import Foundation

struct Program: Codable {
    var program: [ProgramDay]
    var programName: String
    
    enum CodingKeys: String, CodingKey {
        case program = "workout_schedule"
        case programName = "program_name"
        
    }
}
struct ProgramDay: Codable, Hashable {
    var day: String
    var workout: String
    var completed: Bool
    var exercises: [Exercise]
}

struct Exercise: Codable, Hashable {
    var name: String
    var sets: Int
    var reps: Int
    var rpe: String
    var rest: Int
    var completed: Bool
    var data: ExerciseData
}

struct ExerciseData: Codable, Hashable {
    var sets: [ExerciseDataSet]
}

struct ExerciseDataSet: Codable, Hashable {
    var weight: Int
    var reps: Int
    var time: Double
    var rest: Double
}

