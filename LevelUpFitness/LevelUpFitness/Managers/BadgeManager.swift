//
//  BadgeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/10/24.
//

import Foundation

@MainActor
class BadgeManager: ObservableObject {
    static let shared = BadgeManager()
    
    @Published var userBadgeInfo: UserBadgeInfo?
    @Published var badges: [Badge] = []
    
    init() {
        // Badge service is disabled in the current CloudKit-only flow.
    }
}
