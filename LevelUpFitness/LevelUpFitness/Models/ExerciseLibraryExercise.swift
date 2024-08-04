//
//  ExerciseLibraryExercise.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import Foundation

struct ExerciseLibraryExercise: Codable {
    var id: String
    var cdnURL: String
    var name: String
    var description: String
    var bodyArea: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case cdnURL = "CDNURL"
        case description = "Description"
        case bodyArea = "BodyArea"
    }
}
