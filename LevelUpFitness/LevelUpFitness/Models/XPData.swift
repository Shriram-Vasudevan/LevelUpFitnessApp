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
    var lowerBodyCompound : XPAttribute
    var lowerBodyIsolation : XPAttribute
    var upperBodyCompound : XPAttribute
    var upperBodyIsolation : XPAttribute


    enum CodingKeys: String, CodingKey {
        case lowerBodyCompound = "Lower Body Compound"
        case lowerBodyIsolation = "Lower Body Isolation"
        case upperBodyCompound = "Upper Body Compound"
        case upperBodyIsolation = "Upper Body Isolation"
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
