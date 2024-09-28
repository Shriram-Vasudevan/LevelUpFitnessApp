//
//  TrendCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/27/24.
//

import CloudKit
import Foundation

class TrendCloudKitUtility {
    static let customContainer = CKContainer(identifier: "iCloud.LevelUpFitnessCloudKitStorage")
    
    // MARK: - Save Weight Entry to CloudKit
    static func saveWeightEntry(userID: String, weight: Double, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let record = CKRecord(recordType: "WeightTrendData")
        
        record["UserID"] = userID as CKRecordValue
        record["Weight"] = weight as CKRecordValue
        record["Timestamp"] = Date() as CKRecordValue
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Fetch Weight Trend from CloudKit
    static func fetchWeightTrend(userID: String, days: Int, completion: @escaping ([HealthDataPoint]?, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@", userID)
        let query = CKQuery(recordType: "WeightTrendData", predicate: predicate)
        
        // Sort by timestamp, descending order
        query.sortDescriptors = [NSSortDescriptor(key: "Timestamp", ascending: false)]
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var trendData: [HealthDataPoint] = []
            records?.forEach { record in
                if let weight = record["Weight"] as? Double,
                   let timestamp = record["Timestamp"] as? Date {
                    let healthDataPoint = HealthDataPoint(date: timestamp, value: weight)
                    trendData.append(healthDataPoint)
                }
            }
            completion(trendData, nil)
        }
    }
    
    // MARK: - Save Level Entry to CloudKit
    static func saveLevelEntry(userID: String, level: Int, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let record = CKRecord(recordType: "LevelTrendData")
        
        record["UserID"] = userID as CKRecordValue
        record["Level"] = level as CKRecordValue
        record["Timestamp"] = Date() as CKRecordValue
        
        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
    
    // MARK: - Fetch Level Trend from CloudKit
    static func fetchLevelTrend(userID: String, days: Int, completion: @escaping ([HealthDataPoint]?, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@", userID)
        let query = CKQuery(recordType: "LevelTrendData", predicate: predicate)
        
        // Sort by timestamp, descending order
        query.sortDescriptors = [NSSortDescriptor(key: "Timestamp", ascending: false)]
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            var trendData: [HealthDataPoint] = []
            records?.forEach { record in
                if let level = record["Level"] as? Int,
                   let timestamp = record["Timestamp"] as? Date {
                    let healthDataPoint = HealthDataPoint(date: timestamp, value: Double(level))
                    trendData.append(healthDataPoint)
                }
            }
            completion(trendData, nil)
        }
    }
}
