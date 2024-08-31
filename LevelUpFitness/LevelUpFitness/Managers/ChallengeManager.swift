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
    
    func challengeManagerInitialization() async {
        async let getChallengeTemplates: () = getChallengeTemplates()
        async let getActiveUserChallenges: () = getActiveUserChallenges()
        
        _ = await(getChallengeTemplates, getActiveUserChallenges)
    }
    
    func getChallengeTemplates() async {
        do {
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getChallengeTemplates")
            
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
            let activeChallengesRequest = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getActiveUserChallenges", queryParameters: ["UserID" : userID])
            
            let activeChallengesResponse = try await Amplify.API.get(request: activeChallengesRequest)
            
            print("get active user challenges response: \(String(describing: String(data: activeChallengesResponse, encoding: .utf8)))")
            let decoder = JSONDecoder()
            var userChallenges = try decoder.decode([UserChallenge].self, from: activeChallengesResponse)
            
            let originalUserChallengesCount = userChallenges.count
            let isoFormatter = ISO8601DateFormatter()
            
            userChallenges.removeAll { UserChallenge in
                isoFormatter.date(from: UserChallenge.endDate) ?? Date() < Date()
            }
            
            self.userChallenges = userChallenges
            
            if self.userChallenges.count < originalUserChallengesCount {
                await LevelChangeManager.shared.createNewLevelChange(property: "ChallengeFailed", contribution: (originalUserChallengesCount - userChallenges.count) * -10)
                await XPManager.shared.addXPToDB()
            }
            
            let checkChallengeExpiryRequest = RESTRequest(apiName: "LevelUpFitnessChallengeAPI", path: "/checkChallengeExpiry", queryParameters: ["UserID" : userID])
            _ = try await Amplify.API.delete(request: checkChallengeExpiryRequest)
        } catch {
            print("get active user challenges error \(error)")
        }
        
    }
    
    func createChallenge(challengeName: String, challengeTemplateID: String, userXPData: XPData) async {
        switch challengeName {
            case "30 Day LevelUp Challenge":
                let levelsRequired = levelsRequired(currentLevel: userXPData.level)
                guard let dateRange = DateUtility.createDateDurationISO(duration: 30) else { return }
            
            await updateChallenge(challengeTemplateID: challengeTemplateID, challengeName: challengeName, startDate: dateRange.0, endDate: dateRange.1, startValue: userXPData.level, targetValue: userXPData.level + levelsRequired, field: "Level")
            case "Perfect Program Week":
                if let program = ProgramManager.shared.program {
                    let daysRequired = program.program.count
                    guard let dateRange = DateUtility.createDateDurationISO(duration: 7) else { return }
                    
                    switch program.getConsecutiveCompletionDays() {
                        case .success(let consecutiveDays):
                        await updateChallenge(challengeTemplateID: challengeTemplateID, challengeName: challengeName, startDate: dateRange.0, endDate: dateRange.1, startValue: consecutiveDays, targetValue: daysRequired, field: "Level")
                        case .failure(let error):
                            print("Error: \(error.localizedDescription)")
                    }
                }
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
            
            var completedChallenges: [CompletedChallenge] = []
            
            for applicableChallenge in applicableChallenges {
                if applicableChallenge.targetValue == newValue {
                    completedChallenges.append(CompletedChallenge(challengeID: applicableChallenge.id, challengeTemplateID: applicableChallenge.challengeTemplateID))
                }
            }
            
            if completedChallenges.count > 0 {
                let jsonData = try JSONEncoder().encode(completedChallenges)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else { return }
                
                let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/challengesCompleted", queryParameters: ["UserID" : userID, "CompletedChallenges": jsonString])
                let response = try await Amplify.API.put(request: request)
                
                await LevelChangeManager.shared.createNewLevelChange(property: "ChallengeSuccess", contribution: completedChallenges.count * 10) 
                await XPManager.shared.addXPToDB()
                
                GlobalCoverManager.shared.showChallengeCompletion()
            }
        } catch {
            print("challenge completion error \(error)")
        }
    }
    
    
    func levelsRequired(currentLevel: Int, k: Double = 5.0) -> Int {
        let requiredLevels = Int(ceil(k / sqrt(Double(currentLevel))))
        
        return max(requiredLevels, 1)
    }
}
