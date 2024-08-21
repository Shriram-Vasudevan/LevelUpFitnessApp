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
    
    let allProperties = ["Weight", "Rest", "Endurance", "Consistency",]
    var currentProperties: [String] = []
    
    init() {
        Task {
            await getUserXPData()
        }
    }
    
    func getUserXPData() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            var request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserXP", queryParameters: ["UserID" : userID])
            
            let response = try await Amplify.API.get(request: request)
            
            print("xp response: \(String(data: response, encoding: .utf8))")
            let decoder = JSONDecoder()
            let responseDecoded = try decoder.decode(XPDataResponse.self, from: response)
            
            DispatchQueue.main.async {
                self.userXPData = responseDecoded.item
            }
            
            await LevelChangeManager.shared.getLevelChanges()
            await LevelChangeManager.shared.addNewProgramLevelChanges()
            
        } catch {
            print("xp error \(error)")
        }
    }
    
    func addXP(increment: Int, type: XPAdditionType) {
        print("add xp user xp \(userXPData)")
        guard var userXPData = userXPData else {
            print("User XP data is not available.")
            return
        }
        
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
                print("new xp \(userXPData.xp)")
                
            
                let newLevel = calculateLevel(fromXP: userXPData.xp)
                userXPData.level = newLevel
                        
                userXPData.xpNeeded = calculateXPForLevel(newLevel)
                
                Task {
                    await ChallengeManager.shared.checkForChallengeCompletion(challengeField: "Level", newValue: userXPData.level)
                }
        }
        
        self.userXPData = userXPData
        print("the new xp data \(self.userXPData)")
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

            print(String(data: jsonData, encoding: .utf8))
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/updateUserXP", body: jsonData)
            let restResponse = try await Amplify.API.put(request: request)
            
            print("Update XP Response: \(String(data: restResponse, encoding: .utf8))")
        } catch {
            print("Update XP \(error)")
        }
    }
    
    func calculateLevel(fromXP xp: Int) -> Int {
        if xp < 50 {
            return 1
        }

        var level = 1
        var accumulatedXP = 50
        var nextLevelXP = 30

        while xp >= accumulatedXP + nextLevelXP {
            accumulatedXP += nextLevelXP
            level += 1
            nextLevelXP = level * 30
        }

        return level
    }

    func calculateXPForLevel(_ level: Int) -> Int {
        return level == 1 ? 50 : 50 + (level - 1) * (level + 1) * 15
    }
}
