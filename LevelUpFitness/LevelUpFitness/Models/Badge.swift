//
//  Badge.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/10/24.
//

import Foundation

struct Badge: Codable {
    let id: String
    let badgeName: String
    let badgeIconS3URL: String
    let badgeCriteria: BadgeCriteria
}

struct BadgeCriteria: Codable {
    let field: String
    let threshold: Int
}
