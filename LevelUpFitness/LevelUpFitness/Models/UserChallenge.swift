//
//  UserChallenge.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/13/24.
//

import Foundation

struct UserChallenge: Codable {
    var userID: String
    var id: String
    var challengeTemplateID: String
    var startDate: String
    var endDate: String
    var startValue: Int
    var targetValue: Int
    var field: String
    var isFailed: Bool
    var isActive: Bool
    
    private enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case id = "ID"
        case challengeTemplateID = "ChallengeTemplateID"
        case startDate = "StartDate"
        case endDate = "EndDate"
        case startValue = "StartValue"
        case targetValue = "TargetValue"
        case field = "Field"
        case isFailed = "IsFailed"
        case isActive = "IsActive"
    }
}
