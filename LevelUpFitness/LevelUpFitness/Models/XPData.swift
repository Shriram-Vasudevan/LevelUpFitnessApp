//
//  XPData.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import Foundation

struct XPData: Codable {
    var userID: String
    var xp: Int
    var level: Int
    var xpNeeded: Int
    var subLevels: Sublevels
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
        case xp = "XP"
        case level = "Level"
        case xpNeeded = "XPNeeded"
        case subLevels = "Sublevels"
    }
}

struct Sublevels: Codable {
    var strength: Sublevel
    var power: Sublevel
    var endurance: Sublevel
    var mobility: Sublevel
    
    enum CodingKeys: String, CodingKey {
        case strength = "Strength"
        case power = "Power"
        case endurance = "Endurance"
        case mobility = "Mobility"
    }
}

struct Sublevel: Codable {
    var level: Int
    var xp: Int
    var xpNeeded: Int
    
    enum CodingKeys: String, CodingKey {
        case level = "Level"
        case xp = "XP"
        case xpNeeded = "XPNeeded"
    }
}

struct XPDataResponse: Codable {
    var item: XPData
    
    enum CodingKeys: String, CodingKey {
        case item = "Item"
    }
}
