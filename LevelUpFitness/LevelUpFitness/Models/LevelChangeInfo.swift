//
//  LevelChangeInfo.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

struct LevelChangeInfo: Codable {
    var id: String = UUID().uuidString
    var keyword: String
    var description: String
    var change: Int
    var timestamp: Date
}
