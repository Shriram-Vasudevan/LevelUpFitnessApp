//
//  XPCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/27/24.
//

import Foundation

import CloudKit
import Foundation

class XPCloudKitUtility {
    
    static let customContainer = CKContainer(identifier: "iCloud.LevelUpFitnessCloudKitStorage")

    static func fetchUserXPData(userID: String, completion: @escaping (XPData?, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase

        let predicate = NSPredicate(format: "UserID == %@", userID)
        let query = CKQuery(recordType: "XPData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let record = records?.first else {
                let newXPData = XPData(
                    userID: userID,
                    level: 1,
                    xp: 0,
                    xpNeeded: 50,
                    subLevels: Sublevels(
                        lowerBodyCompound: XPAttribute(xp: 0, level: 1, xpNeeded: 25),
                        lowerBodyIsolation: XPAttribute(xp: 0, level: 1, xpNeeded: 25),
                        upperBodyCompound: XPAttribute(xp: 0, level: 1, xpNeeded: 25),
                        upperBodyIsolation: XPAttribute(xp: 0, level: 1, xpNeeded: 25)
                    )
                )
                saveUserXPData(xpData: newXPData) { success, error in
                    if success {
                        completion(newXPData, nil)
                    } else {
                        completion(nil, error)
                    }
                }
                return
            }

            guard let xpData = try? decodeXPData(from: record) else {
                completion(nil, NSError(domain: "XPDataDecodeError", code: 1001, userInfo: nil))
                return
            }
            completion(xpData, nil)
        }
    }

    static func saveUserXPData(xpData: XPData, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let record = CKRecord(recordType: "XPData")

        record["UserID"] = xpData.userID as CKRecordValue
        record["Level"] = xpData.level as CKRecordValue
        record["XP"] = xpData.xp as CKRecordValue
        record["XPNeeded"] = xpData.xpNeeded as CKRecordValue

        if let encodedSubLevels = try? encodeXPDataToCKRecord(xpData.subLevels) {
            record["Sublevels"] = encodedSubLevels as CKRecordValue
        }

        privateDatabase.save(record) { savedRecord, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    static func updateUserXPData(xpData: XPData, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        
        let predicate = NSPredicate(format: "UserID == %@", xpData.userID)
        let query = CKQuery(recordType: "XPData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let record = records?.first else {
                completion(false, error)
                return
            }
            
            record["Level"] = xpData.level as CKRecordValue
            record["XP"] = xpData.xp as CKRecordValue
            record["XPNeeded"] = xpData.xpNeeded as CKRecordValue
            
            if let encodedSubLevels = try? encodeXPDataToCKRecord(xpData.subLevels) {
                record["Sublevels"] = encodedSubLevels as CKRecordValue
            }
            
            privateDatabase.save(record) { savedRecord, error in
                if let error = error {
                    completion(false, error)
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    // Helper: Encode Sublevels to CKRecord-compatible format
    static func encodeXPDataToCKRecord(_ subLevels: Sublevels) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(subLevels)
    }

    // Helper: Decode XPData from a CKRecord
    static func decodeXPData(from record: CKRecord) throws -> XPData {
        guard let userID = record["UserID"] as? String,
              let level = record["Level"] as? Int,
              let xp = record["XP"] as? Int,
              let xpNeeded = record["XPNeeded"] as? Int,
              let sublevelsData = record["Sublevels"] as? Data else {
            throw NSError(domain: "XPDataDecodeError", code: 1002, userInfo: nil)
        }

        let decoder = JSONDecoder()
        let subLevels = try decoder.decode(Sublevels.self, from: sublevelsData)

        return XPData(userID: userID, level: level, xp: xp, xpNeeded: xpNeeded, subLevels: subLevels)
    }
}
