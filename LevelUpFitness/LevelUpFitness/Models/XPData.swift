//
//  XPData.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import Foundation

struct XPData: Codable {
    var userID: String
    var level: Int
    var xp: Int
    var xpNeeded: Int
    var subLevels: Sublevels
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case level = "Level"
        case xp = "XP"
        case xpNeeded = "XPNeeded"
        case subLevels = "Sublevels"
    }
}

struct Sublevels: Codable {
    var mobility: XPAttribute
    var endurance: XPAttribute
    var strength: XPAttribute
    var bodyAreas: BodyAreas

    enum CodingKeys: String, CodingKey {
        case mobility = "Mobility"
        case endurance = "Endurance"
        case strength = "Strength"
        case bodyAreas = "BodyAreas"
    }
}

struct BodyAreas: Codable {
    var back: XPAttribute
    var legs: XPAttribute
    var chest: XPAttribute
    var shoulders: XPAttribute
    var core: XPAttribute

    enum CodingKeys: String, CodingKey {
        case back = "Back"
        case legs = "Legs"
        case chest = "Chest"
        case shoulders = "Shoulders"
        case core = "Core"
    }
    
}

struct XPAttribute: Codable {
    var xp: Int
    var level: Int
    var xpNeeded: Int

    enum CodingKeys: String, CodingKey {
        case xp = "XP"
        case level = "Level"
        case xpNeeded = "XPNeeded"
    }
}

struct XPDataResponse: Codable {
    var item: XPData
    
    enum CodingKeys: String, CodingKey {
        case item = "Item"
    }
}
