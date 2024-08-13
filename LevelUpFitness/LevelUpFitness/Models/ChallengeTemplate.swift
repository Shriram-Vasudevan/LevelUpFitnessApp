//
//  ChallengeTemplate.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/13/24.
//

import Foundation

struct ChallengeTemplate: Codable, Identifiable {
    var id: String
    var name: String
    var description: String
    var duration: Int
    var targetField: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case description = "Description"
        case duration = "Duration"
        case targetField = "TargetField"
    }
}
