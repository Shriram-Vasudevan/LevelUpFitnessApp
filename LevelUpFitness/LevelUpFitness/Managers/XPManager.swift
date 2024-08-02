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
    
    func addXPLocally(todaysProgram: ProgramDay) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            guard var userXPData = userXPData else {
                print("User XP data is not available.")
                return
            }
            
            var totalIncrement = 0
            let completedCount = todaysProgram.exercises.filter({ $0.completed }).count
            
     
            totalIncrement += completedCount
            
            let currentXP = userXPData.xp
            let xpNeeded = userXPData.xpNeeded
            
            let newXP = currentXP + totalIncrement
            let incrementLevel = newXP > xpNeeded
            
            if incrementLevel {
                userXPData.level += 1
                userXPData.xp = newXP
                userXPData.xpNeeded = Int(pow(Double(userXPData.level), 2) * 100)
            } else {
                userXPData.xp = newXP
            }
            
            self.userXPData? = userXPData
            
        
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
