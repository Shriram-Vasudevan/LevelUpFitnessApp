//
//  DatabaseManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import Foundation
import AWSAPIPlugin
import Amplify
import AWSCognitoAuthPlugin

class DatabaseManager: ObservableObject {
    @Published var workouts: [Workout] = []
    
    func getWorkouts() async {
        do {
            guard let userID = try? await Amplify.Auth.getCurrentUser().userId else { return }
            
            print(userID)
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getWorkouts", queryParameters: ["UserID" : userID])
            let response = try await Amplify.API.get(request: request)
            
            let stringResponse = String(data: response, encoding: .utf8)
            print("got user workouts: \(String(describing: stringResponse))")
            
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .custom { keys in
                let lastKey = keys.last!
                
                if lastKey.stringValue == "WorkoutID" {
                    return PascalCaseKey(stringValue: "id")
                }
                else {
                    return PascalCaseKey(stringValue: lastKey.stringValue)
                }
            }
            
            let workouts = try jsonDecoder.decode([Workout].self, from: response)
            
            DispatchQueue.main.async {
                self.workouts = workouts
            }
            
        } catch {
            print(error)
        }
    }
}
