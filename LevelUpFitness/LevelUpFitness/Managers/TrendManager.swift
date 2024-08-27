//
//  TrendManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/27/24.
//

import Foundation
import Amplify

@MainActor
class TrendManager: ObservableObject {
    static let shared = TrendManager()
    
    @Published var weightTrend: [HealthDataPoint] = []
    
    func addWeightToTrend(weight: Double) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/addWeightEntry", queryParameters: ["UserID" : userID, "Weight": "\(weight)"])
            let response = try await Amplify.API.put(request: request)
            
            let jsonString = String(data: response, encoding: .utf8)
            
//            let isoFormatter = ISO8601DateFormatter()
//            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
//            
//            let date = isoFormatter.string(from: Date())
            
            self.weightTrend.append(HealthDataPoint(date: Date(), value: weight))
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
            print("get weight trend string \(jsonString ?? "")")
            
            if let jsonArray = try JSONSerialization.jsonObject(with: response) as? [[String: Any]] {
                print(jsonArray)
                for jsonObject in jsonArray {
                    print(jsonObject)
                    
                    for (key, value) in jsonObject {
                        print("Key: \(key), Value: \(value)")
                    }
                    
                    if let timeStamp = jsonObject["Timestamp"] as? String {
                        print("Timestamp: \(timeStamp)")
                        
                        if let weightValue = jsonObject["Weight"] {
                            print("Raw Weight value: \(weightValue)")
                            print("Type of Weight value: \(type(of: weightValue))")
                            
                            if let weightString = weightValue as? String {
                                if let weightDouble = Double(weightString) {
                                    print("Successfully converted Weight to Double: \(weightDouble)")
                                    let isoFormatter = ISO8601DateFormatter()
                                    isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                    
                                    if let date = isoFormatter.date(from: timeStamp) {
                                        print("Successfully parsed Date: \(date)")
                                        
                                        self.weightTrend.append(HealthDataPoint(date: date, value: weightDouble))
                                        print("Appended weight to weightTrend: \(self.weightTrend.last)")
                                    } else {
                                        print("Failed to parse Date from Timestamp: \(timeStamp)")
                                    }
                                } else {
                                    print("Failed to convert Weight String to Double. Weight String: \(weightString)")
                                }
                            } else {
                                print("Weight is neither a String nor a Double, actual type: \(type(of: weightValue))")
                            }
                        } else {
                            print("Weight key not found")
                        }
                    } else {
                        print("Couldn't get Timestamp as String")
                    }
                }
            } else {
                print("Couldn't parse response as JSON array")
            }
            
        } catch {
            print(error)
        }
    }
}
