//
//  UserBadgeInfo.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/10/24.
//

import Foundation

struct UserBadgeInfo: Codable, Equatable {
    var userId: String
    var weeks: Int
    var badgesEarned: [String]
}
