//
//  XPManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import Foundation
import CloudKit

@MainActor
class XPManager: ObservableObject {
    static let shared = XPManager()
    
    @Published var userXPData: XPData?
    @Published var levelChanges: [LevelChangeInfo] = []
    @Published var xpDataModified = false

    let allProperties = ["Weight", "Rest", "Endurance", "Consistency"]
    var currentProperties: [String] = []

    private var xpCallCounter = 0
    private var lastXPCallTimestamp: Date?

    func xpManagerInit() async {
        do {
            let userID = try await XPCloudKitUtility.customContainer.userRecordID().recordName
            XPCloudKitUtility.fetchUserXPData(userID: userID) { data, error in
                if let xpData = data {
                    DispatchQueue.main.async {
                        self.userXPData = xpData
                    }
                    Task {
                        await TrendManager.shared.addLevelToTrend(level: self.userXPData?.level ?? 0)
                    }
                } else if let error = error {
                    print("Error fetching XPData: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error initializing XPManager: \(error.localizedDescription)")
        }
    }
    
    func addXP(increment: Int, type: XPAdditionType) {
        guard var userXPData = userXPData else {
            print("User XP data is not available.")
            return
        }
        
        xpDataModified = true
        
        switch type {
            case .lowerBodyCompound:
                userXPData.subLevels.lowerBodyCompound.incrementXP(increment: increment)
            case .lowerBodyIsolation:
                userXPData.subLevels.lowerBodyIsolation.incrementXP(increment: increment)
            case .upperBodyCompound:
                userXPData.subLevels.upperBodyCompound.incrementXP(increment: increment)
            case .upperBodyIsolation:
                userXPData.subLevels.upperBodyIsolation.incrementXP(increment: increment)
            case .total:
                userXPData.xp += increment
                let newLevel = calculateLevel(fromXP: userXPData.xp)
                userXPData.level = newLevel.0
                userXPData.xpNeeded = calculateXPForLevel(newLevel.0)
        }
        
        cacheUserXP(userXPData: userXPData)
        self.userXPData = userXPData
    }
    
    func addXPToDB() {
        guard let userXPData = userXPData else { return }
        
         XPCloudKitUtility.updateUserXPData(xpData: userXPData) { success, error in
            if success {
                print("User XP data updated in CloudKit")
            } else if let error = error {
                print("Failed to update XP data: \(error.localizedDescription)")
            }
        }
    }

    func cacheUserXP(userXPData: XPData) {
        // Local caching for offline support
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(userXPData)
            guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("userXPData.json") else {
                print("Failed to resolve documents directory for XP cache.")
                return
            }
            try data.write(to: fileURL)
            print("User XP data cached successfully.")
        } catch {
            print("Failed to cache user XP data: \(error.localizedDescription)")
        }
    }

    func calculateLevel(fromXP xp: Int) -> (Int, Bool) {
        var level = 1
        var accumulatedXP = 50
        while xp >= accumulatedXP {
            level += 1
            accumulatedXP += level * 30
        }
        return (level, level > userXPData?.level ?? 1)
    }

    func calculateXPForLevel(_ level: Int) -> Int {
        if level <= 1 {
            return 50
        }
        
        var totalXP = 50
        for currentLevel in 2...level {
            totalXP += currentLevel * 30
        }
        return totalXP
    }
}
