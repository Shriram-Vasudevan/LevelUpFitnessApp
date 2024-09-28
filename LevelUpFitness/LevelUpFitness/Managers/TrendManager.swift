//
//  TrendManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/27/24.
//

import Foundation
import CloudKit

@MainActor
class TrendManager: ObservableObject {
    static let shared = TrendManager()
    
    @Published var weightTrend: [HealthDataPoint] = []
    @Published var levelTrend: [HealthDataPoint] = []
    
    // MARK: - Add Weight to Trend
    func addWeightToTrend(weight: Double) async {
        do {
            let userID = try await TrendCloudKitUtility.customContainer.userRecordID().recordName
            TrendCloudKitUtility.saveWeightEntry(userID: userID, weight: weight) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.weightTrend.append(HealthDataPoint(date: Date(), value: weight))
                    }
                } else if let error = error {
                    print("Failed to save weight entry: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user ID: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get Weight Trend
    func getWeightTrend() async {
        do {
            let userID = try await TrendCloudKitUtility.customContainer.userRecordID().recordName
            await TrendCloudKitUtility.fetchWeightTrend(userID: userID, days: 30) { trendData, error in
                if let trendData = trendData {
                    DispatchQueue.main.async {
                        self.weightTrend = trendData
                    }
                } else if let error = error {
                    print("Failed to fetch weight trend: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user ID: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Add Level to Trend
    func addLevelToTrend(level: Int) async {
        do {
            let userID = try await TrendCloudKitUtility.customContainer.userRecordID().recordName
            TrendCloudKitUtility.saveLevelEntry(userID: userID, level: level) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.levelTrend.append(HealthDataPoint(date: Date(), value: Double(level)))
                    }
                } else if let error = error {
                    print("Failed to save level entry: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user ID: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Get Level Trend
    func getLevelTrend() async {
        do {
            let userID = try await TrendCloudKitUtility.customContainer.userRecordID().recordName
            TrendCloudKitUtility.fetchLevelTrend(userID: userID, days: 30) { trendData, error in
                if let trendData = trendData {
                    DispatchQueue.main.async {
                        self.levelTrend = trendData
                    }
                } else if let error = error {
                    print("Failed to fetch level trend: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user ID: \(error.localizedDescription)")
        }
    }
}
