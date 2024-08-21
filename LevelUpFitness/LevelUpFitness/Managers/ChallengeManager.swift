//
//  ChallengeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/10/24.
//

import Foundation
import Amplify

@MainActor
class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()
    
    @Published var challengeTemplates: [ChallengeTemplate] = []
    @Published var userChallenges: [UserChallenge] = []
    
    init() {
        Task {
            async let getChallengeTemplates: () = getChallengeTemplates()
            async let getActiveUserChallenges: () = getActiveUserChallenges()
            
            _ = await(getChallengeTemplates, getActiveUserChallenges)
        }
    }
    func getChallengeTemplates() async {
        do {
            var request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getChallengeTemplates")
            
            let response = try await Amplify.API.get(request: request)
            
           // print("get challenge templates response: \(String(describing: String(data: response, encoding: .utf8)))")
            let decoder = JSONDecoder()
            let responseDecoded = try decoder.decode([ChallengeTemplate].self, from: response)
            
            self.challengeTemplates = responseDecoded
        } catch {
            print(error)
        }
        
    }
    
    func getActiveUserChallenges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            var request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getActiveUserChallenges", queryParameters: ["UserID" : userID])
            
            let response = try await Amplify.API.get(request: request)
            
          //  print("get active user challenges response: \(String(describing: String(data: response, encoding: .utf8)))")
            let decoder = JSONDecoder()
            let responseDecoded = try decoder.decode([UserChallenge].self, from: response)
            
            self.userChallenges = responseDecoded
        } catch {
            print(error)
        }
        
    }
    
    func createChallenge(challengeName: String, challengeTemplateID: String, userXPData: XPData) async {
        switch challengeName {
            case "30 Day LevelUp Challenge":
                let levelsRequired = levelsRequired(currentLevel: userXPData.level)
                guard let dateRange = DateUtility.createDateDurationISO(duration: 30) else { return }
            
            await updateChallenge(challengeTemplateID: challengeTemplateID, challengeName: challengeName, startDate: dateRange.0, endDate: dateRange.1, startValue: userXPData.level, targetValue: userXPData.level + levelsRequired, field: "Level")
            default:
                break
        }
    }
    
    func updateChallenge(challengeTemplateID: String, challengeName: String, startDate: String, endDate: String, startValue: Int, targetValue: Int, field: String) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            //print("challenge template id \(challengeTemplateID)")
            let userChallenge = UserChallenge(userID: userID, id: UUID().uuidString, challengeTemplateID: challengeTemplateID, name: challengeName, startDate: startDate, endDate: endDate, startValue: startValue, targetValue: targetValue, field: field, isFailed: false, isActive: true)
            
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(userChallenge)
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/updateChallenge", body: jsonData)
            
            let response = try await Amplify.API.put(request: request)
            
          //  print("updateChallenge response: \(String(describing: String(data: response, encoding: .utf8)))")
            
            userChallenges.append(userChallenge)
        } catch {
            print(error)
        }
    }
    
    func checkForChallengeCompletion(challengeField: String, newValue: Int) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            let applicableChallenges = self.userChallenges.filter({ $0.field == challengeField })
            
            var completedChallenges: [String] = []
            
            for applicableChallenge in applicableChallenges {
                if applicableChallenge.targetValue == newValue {
                    XPManager.shared.addXP(increment: 10, type: .total)
                    completedChallenges.append(applicableChallenge.id)
                }
            }
            
//            if completedChallenges.count > 0 {
//                let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/challengesCompleted", queryParameters: ["UserID" : userID, "CompletedChallenges": completedChallenges])
//                let response = try await Amplify.API.put(request: request)
//            }
        } catch {
            print("challenge completion error \(error)")
        }
    }
    
    
    func levelsRequired(currentLevel: Int, k: Double = 5.0) -> Int {
        let requiredLevels = Int(ceil(k / sqrt(Double(currentLevel))))
        
        return max(requiredLevels, 1)
    }
}
