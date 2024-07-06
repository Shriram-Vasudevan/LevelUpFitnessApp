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
    
    
    enum CodingKeys: String, CodingKey {
        case userID = "UserID"
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
