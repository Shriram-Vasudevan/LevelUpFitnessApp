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
            
            print("get challenge templates response: \(String(describing: String(data: response, encoding: .utf8)))")
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
            
            print("get active user challenges response: \(String(describing: String(data: response, encoding: .utf8)))")
            let decoder = JSONDecoder()
            let responseDecoded = try decoder.decode([UserChallenge].self, from: response)
            
            self.userChallenges = responseDecoded
        } catch {
            print(error)
        }
        
    }
    
    func startChallenge(challengeTemplateID: String, startDate: String, endDate: String, startValue: Int, targetValue: Int, field: String) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let userChallenge = UserChallenge(userID: userID, id: UUID().uuidString, challengeTemplateID: challengeTemplateID, startDate: startDate, endDate: endDate, startValue: startValue, targetValue: targetValue, field: field, isFailed: false, isActive: true)
            
            let jsonData = try JSONSerialization.data(withJSONObject: userChallenge, options: .prettyPrinted)
            
            var request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/startChallenge", body: jsonData)
            
            let response = try await Amplify.API.put(request: request)
            
            print("start challenge response: \(String(describing: String(data: response, encoding: .utf8)))")
            
            userChallenges.append(userChallenge)
        } catch {
            print(error)
        }
    }
    
}
