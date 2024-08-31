//
//  ProgramDBRepresentation.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/9/24.
//

import Foundation

struct UserProgramDBRepresentation: Codable {
    var userID: String
    var program: String
    var startDate: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case program = "Program"
        case startDate = "StartDate"
    }
}

struct StandardProgramDBRepresentation: Codable {
    var id: String
    var name: String
    var environment: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case environment = "Environment"
    }
}
