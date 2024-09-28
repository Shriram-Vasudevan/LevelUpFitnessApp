//
//  FirstLaunchManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/28/24.
//

import Foundation


class FirstLaunchManager {
    private let hasLaunchedKey = "hasLaunchedBefore"
    
    static let shared = FirstLaunchManager()
    
    private init() {}
    
    var isFirstLaunch: Bool {
        get {
            return !UserDefaults.standard.bool(forKey: hasLaunchedKey)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: hasLaunchedKey)
        }
    }
    
    func markAsLaunched() {
        isFirstLaunch = false
    }
}
