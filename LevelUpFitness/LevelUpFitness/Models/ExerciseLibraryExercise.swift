//
//  ExerciseLibraryExercise.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import Foundation

struct ExerciseLibraryExercise: Codable, Hashable, Equatable {
    var id: String
    var name: String
    var exerciseType: String
    var progression: [Progression]
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case exerciseType = "ExerciseType"
        case progression = "Progression"
    }
}

struct Progression: Codable, Hashable, Equatable {
    var name: String
    var description: String
    var level: Int
    var cdnURL: String
    var exerciseType: String
}
