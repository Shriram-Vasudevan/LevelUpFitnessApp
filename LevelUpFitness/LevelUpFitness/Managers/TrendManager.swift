//
//  TrendManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/27/24.
//

import Foundation
import Amplify

class TrendManager: ObservableObject {
    static let shared = TrendManager()
    
    @Published var weightTrend: [HealthDataPoint]?
    
    func addWeightToTrend(weight: Double) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/addWeightEntry", queryParameters: ["UserID" : userID, "Weight": "\(weight)"])
            let response = try await Amplify.API.put(request: request)
            
            let jsonString = String(data: response, encoding: .utf8)
        } catch {
            print(error)
        }
    }
    
    func getWeightTrend() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserWeightTrend", queryParameters: ["UserID" : userID, "Days": "\(30)"])
            let response = try await Amplify.API.get(request: request)
            
            let jsonString = String(data: response, encoding: .utf8)
            
            if let jsonArray = try JSONSerialization.jsonObject(with: response) as? [String: Any] {
                if let timeStamp = jsonArray["Timestamp"] as? String, let weight = jsonArray["Weight"] as? Double {
                    let isoFormatter = ISO8601DateFormatter()
                    if let date = isoFormatter.date(from: timeStamp) {
                        self.weightTrend?.append(HealthDataPoint(date: date, value: weight))
                    }
                }
            }
            
        } catch {
            print(error)
        }
    }
}
