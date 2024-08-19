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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicKey.self)
        name = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "Name")!) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "Description")!) ?? ""
        level = try container.decodeIfPresent(Int.self, forKey: DynamicKey(stringValue: "Level")!) ?? 0
        cdnURL = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "CDNURL")!) ?? ""
        exerciseType = try container.decodeIfPresent(String.self, forKey: DynamicKey(stringValue: "ExerciseType")!) ?? ""
    }
}

struct DynamicKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}
