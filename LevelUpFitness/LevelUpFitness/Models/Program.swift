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
    var imageName: String
    var isPremium: Bool

    enum CodingKeys: String, CodingKey {
        case program = "workout_schedule"
        case programName = "program_name"
        case programDuration = "program_duration"
        case startDate = "start_date"
        case startWeekday = "start_week_day"
        case environment = "environment"
        case imageName = "image_name"
        case isPremium = "is_premium"
    }

    init(program: [ProgramDay], programName: String, programDuration: Int, startDate: String, startWeekday: String, environment: String, imageName: String, isPremium: Bool = false) {
        self.program = program
        self.programName = programName
        self.programDuration = programDuration
        self.startDate = startDate
        self.startWeekday = startWeekday
        self.environment = environment
        self.imageName = imageName
        self.isPremium = isPremium
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        program = try container.decode([ProgramDay].self, forKey: .program)
        programName = try container.decode(String.self, forKey: .programName)
        programDuration = try container.decode(Int.self, forKey: .programDuration)
        startDate = try container.decode(String.self, forKey: .startDate)
        startWeekday = try container.decode(String.self, forKey: .startWeekday)
        environment = try container.decode(String.self, forKey: .environment)
        imageName = try container.decode(String.self, forKey: .imageName)
        isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(program, forKey: .program)
        try container.encode(programName, forKey: .programName)
        try container.encode(programDuration, forKey: .programDuration)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(startWeekday, forKey: .startWeekday)
        try container.encode(environment, forKey: .environment)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(isPremium, forKey: .isPremium)
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
    var reps: String
    var rpe: String
    var rest: Int
    var area: String
    var isWeight: Bool
    var completed: Bool
    var cdnURL: String
    var equipment: [String]
    var description: String
    var data: ExerciseData
}

