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
    var programDuration: Int
    var startDate: String
    var startWeekday: String
    var environment: String
    
    enum CodingKeys: String, CodingKey {
        case program = "workout_schedule"
        case programName = "program_name"
        case programDuration = "program_duration"
        case startDate = "start_date"
        case startWeekday = "start_week_day"
        case environment = "environment"
        
    }
}
struct ProgramDay: Codable, Hashable {
    var day: String
    var workout: String
    var completed: Bool
    var exercises: [ProgramExercise]
}

struct ProgramExercise: Codable, Hashable {
    var name: String
    var sets: Int
    var reps: Int
    var rpe: String
    var rest: Int
    var area: String
    var isWeight: Bool
    var completed: Bool
    var cdnURL: String
    var equipment: String
    var data: ExerciseData
}

