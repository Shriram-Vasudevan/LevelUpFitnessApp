//
//  BadgeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/10/24.
//

import Foundation
import AWSAPIPlugin
import Amplify
import AWSCognitoAuthPlugin

@MainActor
class BadgeManager: ObservableObject {
    @Published var userBadgeInfo: UserBadgeInfo?
    @Published var badges: [Badge] = []
    
    init() {
        Task {
            await getBadges()
            await getUserBadgeInfo()
        }
    }
    
    func checkIfBadgesEarned(weeksUpdated: Bool) async {
            print("checking")
        if badges.count > 0 {
            guard var userBadgeInfo = self.userBadgeInfo else { return }
            for badge in badges {
                print("field: \(badge.badgeCriteria.field)")
                if badge.badgeCriteria.field == "Weeks" {
                    if userBadgeInfo.weeks >= badge.badgeCriteria.threshold {
                        print("met: \(badge.badgeCriteria.threshold) and id: \(badge.id)")
                        if !userBadgeInfo.badgesEarned.contains(badge.id) {
                            userBadgeInfo.badgesEarned.append(badge.id)
                        }
                    }
                }
            }
            
            self.userBadgeInfo = userBadgeInfo
            print("the count: \(String(describing: self.userBadgeInfo?.weeks))")
            
            await modifyUserBadgeInfo(userBadgeInfo: userBadgeInfo, weeksUpdated: weeksUpdated)
        }
    }
        
    func modifyUserBadgeInfo(userBadgeInfo: UserBadgeInfo, weeksUpdated: Bool) async {
        print("modifying: \(userBadgeInfo.weeks) and earned: \(userBadgeInfo.badgesEarned) and weeks: \(weeksUpdated)")
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            print("userID \(userID)")
            let object = [
                "UserID": userID,
                "Weeks": weeksUpdated,
                "Badges": userBadgeInfo.badgesEarned
            ] as [String : Any]
            
            let jsonData = try JSONSerialization.data(withJSONObject: object)
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/modifyUserBadgeInfo", body: jsonData)
            let response = try await Amplify.API.put(request: request)
            
            let stringResponse = String(data: response, encoding: .utf8)
            print("modify response: \(String(describing: stringResponse))")
        } catch {
            print("modify error: \(error)")
        }
    }
    
    func getUserBadgeInfo() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserBadgeInfo", queryParameters: ["UserID" : userID])
            let response = try await Amplify.API.get(request: request)
            
            let stringResponse = String(data: response, encoding: .utf8)
            print("got user badge info response: \(String(describing: stringResponse))")
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .custom { keys in
                let lastKey = keys.last!
                
                if lastKey.stringValue == "UserID" {
                    return PascalCaseKey(stringValue: "userId")
                } else {
                    return PascalCaseKey(stringValue: lastKey.stringValue)
                }
            }
            
            let userBadgeInfo = try jsonDecoder.decode(UserBadgeInfo.self, from: response)
            
            self.userBadgeInfo = userBadgeInfo
            print(self.userBadgeInfo?.weeks)
        } catch {
            print("badge info error: \(error)")
        }
    }
    
    func getBadges() async {
        do {
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getBadges")
            let response = try await Amplify.API.get(request: request)
            
            let stringResponse = String(data: response, encoding: .utf8)
            print("got badges response: \(String(describing: stringResponse))")
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .custom { keys in
                let lastKey = keys.last!
                if lastKey.stringValue == "ID" {
                    return PascalCaseKey(stringValue: "id")
                } else {
                    return PascalCaseKey(stringValue: lastKey.stringValue)
                }
            }

            let badges = try jsonDecoder.decode([Badge].self, from: response)
            
            self.badges = badges
        }
        catch {
            print("badge error: \(error)")
        }
    }
    
    
}
