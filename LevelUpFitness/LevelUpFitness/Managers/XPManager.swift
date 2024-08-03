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
    @Published var userXPData: XPData?
    
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
        } catch {
            print("xp error \(error)")
        }
    }
    
    func addXP(increment: Int, type: XPAdditionType) {
        guard var userXPData = userXPData else {
            print("User XP data is not available.")
            return
        }
        
        switch type {
            case .totalXP:
                userXPData.xp += increment
            
                let incrementLevel = userXPData.xp > userXPData.xpNeeded
                if incrementLevel {
                    userXPData.level += 1
                    userXPData.xpNeeded += userXPData.level * 40
                }

            case .strength:
                userXPData.subLevels.strength.xp += increment
            
                let incrementLevel = userXPData.subLevels.strength.xp > userXPData.subLevels.strength.xpNeeded
                if incrementLevel {
                    userXPData.subLevels.strength.level += 1
                    userXPData.subLevels.strength.xpNeeded +=  userXPData.subLevels.strength.level * 20
                }
            case .power:
                userXPData.subLevels.power.xp += increment
            
                let incrementLevel = userXPData.subLevels.power.xp > userXPData.subLevels.power.xpNeeded
                if incrementLevel {
                    userXPData.subLevels.power.level += 1
                    userXPData.subLevels.power.xpNeeded +=  userXPData.subLevels.power.level * 20
                }
            case .endurance:
                userXPData.subLevels.endurance.xp += increment
            
                let incrementLevel = userXPData.subLevels.endurance.xp > userXPData.subLevels.endurance.xpNeeded
                if incrementLevel {
                    userXPData.subLevels.endurance.level += 1
                    userXPData.subLevels.endurance.xpNeeded +=  userXPData.subLevels.endurance.level * 20
                }
            case .mobility:
                userXPData.subLevels.mobility.xp += increment
            
                let incrementLevel = userXPData.subLevels.mobility.xp > userXPData.subLevels.mobility.xpNeeded
                if incrementLevel {
                    userXPData.subLevels.mobility.level += 1
                    userXPData.subLevels.mobility.xpNeeded +=  userXPData.subLevels.mobility.level * 20
                }
            }
        
        self.userXPData = userXPData
    }
    
    func addXPToDB(todaysProgram: ProgramDay) async {
        do {
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
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }

}
