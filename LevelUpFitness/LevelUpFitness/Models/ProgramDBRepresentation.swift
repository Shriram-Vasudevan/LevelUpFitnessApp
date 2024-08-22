//
//  ProgramDBRepresentation.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/9/24.
//

import Foundation

struct ProgramDBRepresentation: Codable {
    var userID: String
    var program: String
    var startDate: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case program = "Program"
        case startDate = "StartDate"
    }
}
