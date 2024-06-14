//
//  ExerciseLibraryExercise.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import Foundation

struct ExerciseLibraryExercise: Codable {
    var name: String
    var cdnURL: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case cdnURL = "CDNURL"
    }
}
