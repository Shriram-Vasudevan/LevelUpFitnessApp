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
            case .strength:
                userXPData.subLevels.strength.incrementXP(increment: increment)
            case .endurance:
                userXPData.subLevels.endurance.incrementXP(increment: increment)
            case .mobility:
                userXPData.subLevels.mobility.incrementXP(increment: increment)
            case .back:
                userXPData.subLevels.bodyAreas.back.incrementXP(increment: increment)
            case .legs:
                userXPData.subLevels.bodyAreas.legs.incrementXP(increment: increment)
            case .core:
                userXPData.subLevels.bodyAreas.core.incrementXP(increment: increment)
            case .shoulders:
                userXPData.subLevels.bodyAreas.shoulders.incrementXP(increment: increment)
            case .chest:
                userXPData.subLevels.bodyAreas.chest.incrementXP(increment: increment)
            }
        
        userXPData.level = userXPData.subLevels.getAverage()
        
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
