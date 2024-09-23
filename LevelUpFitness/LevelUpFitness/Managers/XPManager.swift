//
//  XPManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import Foundation
import Amplify
import AWSAPIPlugin

@MainActor
class XPManager: ObservableObject {
    static let shared = XPManager()
    
    @Published var userXPData: XPData?
    @Published var levelChanges: [LevelChangeInfo] = []

    @Published var xpDataModified = false
    
    let allProperties = ["Weight", "Rest", "Endurance", "Consistency",]
    var currentProperties: [String] = []

    private var xpCallCounter = 0
    private var lastXPCallTimestamp: Date?
    
    func xpManagerInit() async {
        async let getUserXPData: () =  await getUserXPData()
        async let getLevelChanges: () =   await LevelChangeManager.shared.getLevelChanges()
        async let addNewProgramLevelChanges: () =  await LevelChangeManager.shared.addNewProgramLevelChanges()
        _ = await(getUserXPData, getLevelChanges, addNewProgramLevelChanges)
    }
    
    func getUserXPData() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserXP", queryParameters: ["UserID" : userID])
            
            let response = try await Amplify.API.get(request: request)
            
            print("xp response: \(String(describing: String(data: response, encoding: .utf8)))")
            let decoder = JSONDecoder()
            let responseDecoded = try decoder.decode(XPDataResponse.self, from: response)
            
            DispatchQueue.main.async {
                self.userXPData = responseDecoded.item
            }
            
            
        } catch {
            print("xp error \(error)")
        }
    }
    
    func addXP(increment: Int, type: XPAdditionType) {
        let now = Date()
        if let lastCall = lastXPCallTimestamp, now.timeIntervalSince(lastCall) < 1 {
            xpCallCounter += 1
        } else {
            xpCallCounter = 1
            lastXPCallTimestamp = now
        }
        if xpCallCounter > 3 {
            fatalError("addXP function called more than 3 times in a second!")
        }
        
        xpDataModified = true
        print("add xp user xp \(String(describing: userXPData))")
        guard var userXPData = userXPData else {
            print("User XP data is not available.")
            return
        }
        
        switch type {
            case .lowerBodyCompound:
                userXPData.subLevels.lowerBodyCompound.incrementXP(increment: increment)
                ToDoListManager.shared.xpAdded(xp: increment)
            case .lowerBodyIsolation:
                userXPData.subLevels.lowerBodyIsolation.incrementXP(increment: increment)
                ToDoListManager.shared.xpAdded(xp: increment)
            case .upperBodyCompound:
                userXPData.subLevels.upperBodyCompound.incrementXP(increment: increment)
                ToDoListManager.shared.xpAdded(xp: increment)
            case .upperBodyIsolation:
                userXPData.subLevels.upperBodyIsolation.incrementXP(increment: increment)
                ToDoListManager.shared.xpAdded(xp: increment)
            case .total:
                ToDoListManager.shared.xpAdded(xp: increment)
            
                userXPData.xp += increment
                print("new xp \(userXPData.xp)")
                
            
                let newLevel = calculateLevel(fromXP: userXPData.xp)
                userXPData.level = newLevel.0
                        
                userXPData.xpNeeded = calculateXPForLevel(newLevel.0)
                
                Task {
                    if newLevel.1 {
                        await TrendManager.shared.addLevelToTrend(level: newLevel.0)
                    }
                    
                    await ChallengeManager.shared.checkForChallengeCompletion(challengeField: "Level", newValue: userXPData.level)
                }
        }
        
        cacheUserXP(userXPData: userXPData)
        self.userXPData = userXPData
        print("the new xp data \(String(describing: self.userXPData))")
    }
    
    func addXPToDB() async {
        do {
            print("adding to db")
            guard let userXPData = userXPData else {
                print("User XP data is not available.")
                return
            }
            
            print(userXPData)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(userXPData)

            print(String(data: jsonData, encoding: .utf8) as Any)
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/updateUserXP", body: jsonData)
            let restResponse = try await Amplify.API.put(request: request)
            
            print("Update XP Response: \(String(describing: String(data: restResponse, encoding: .utf8)))")
        } catch {
            print("Update XP \(error)")
        }
    }
    
    func cacheUserXP(userXPData: XPData) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not find documents directory")
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent("userXPData.json")
        
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(userXPData)
            
            try data.write(to: fileURL)
            print("User XP data saved successfully at \(fileURL.path)")
            
        } catch {
            print("Failed to save user XP data: \(error.localizedDescription)")
        }
    }
    
    func calculateLevel(fromXP xp: Int) -> (Int, Bool) {
        if xp < 50 {
            return (1, false)
        }
        
        var levelIncremented: Bool = false
        
        var level = 1
        var accumulatedXP = 50

        while xp >= accumulatedXP {
            level += 1
            accumulatedXP += level * 30
            levelIncremented = true
        }

        return (level, levelIncremented)
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
