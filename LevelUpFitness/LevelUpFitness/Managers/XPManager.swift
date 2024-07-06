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
    
    func addXPLocally(increment: Int) async {
        guard var userXPData = userXPData else {
            print("User XP data is not available.")
            return
        }
        
        let currentXP = userXPData.xp
        let xpNeeded = userXPData.xpNeeded
        
        let newXP = currentXP + increment
        let incrementLevel = newXP > xpNeeded
        
        if incrementLevel {
            userXPData.level += 1
            userXPData.xp = newXP
            userXPData.xpNeeded = Int(pow(Double(userXPData.level), 2) * 100)
        } else {
            userXPData.xp = newXP
        }
        self.userXPData? = userXPData
        
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            var request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/addUserXP", queryParameters: ["UserID" : userID, "incrementAmount": "\(increment)", "incrementLevel": "\(incrementLevel)"])
            
            let response = try await Amplify.API.put(request: request)
            
            print("modify response: \(String(data: response, encoding: .utf8))")
        } catch {
            print("xp error \(error)")
        }
    }

}
