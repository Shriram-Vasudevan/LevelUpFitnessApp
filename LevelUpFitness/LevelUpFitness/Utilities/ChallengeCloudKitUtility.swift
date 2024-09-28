//
//  ChallengeCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/27/24.
//

import CloudKit
import Foundation

import CloudKit
import Foundation

class ChallengeCloudKitUtility {

    // Custom CloudKit Container
    static let customContainer = CKContainer(identifier: "iCloud.LevelUpFitnessCloudKitStorage")

    // MARK: - Fetch Challenge Templates
    static func fetchChallengeTemplates(completion: @escaping ([ChallengeTemplate]?, Error?) -> Void) {
        let publicDatabase = customContainer.publicCloudDatabase
        let query = CKQuery(recordType: "ChallengeTemplate", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching challenge templates: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            let templates = records?.compactMap { record -> ChallengeTemplate? in
                guard let id = record["ID"] as? String,
                      let name = record["Name"] as? String,
                      let description = record["Description"] as? String,
                      let duration = record["Duration"] as? Int,
                      let targetField = record["TargetField"] as? String else {
                    return nil
                }
                
                return ChallengeTemplate(id: id, name: name, description: description, duration: duration, targetField: targetField)
            } ?? []
            
            completion(templates, nil)
        }
    }

    // MARK: - Fetch User Challenges
    static func fetchUserChallenges(userID: String, completion: @escaping ([UserChallenge]?, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@", userID)
        let query = CKQuery(recordType: "UserChallenge", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching user challenges: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            let userChallenges = records?.compactMap { record -> UserChallenge? in
                guard let userID = record["UserID"] as? String,
                      let challengeTemplateID = record["ChallengeTemplateID"] as? String,
                      let name = record["Name"] as? String,
                      let startDate = record["StartDate"] as? String,
                      let endDate = record["EndDate"] as? String,
                      let startValue = record["StartValue"] as? Int,
                      let targetValue = record["TargetValue"] as? Int,
                      let field = record["Field"] as? String,
                      let isFailed = record["IsFailed"] as? Bool,
                      let isActive = record["IsActive"] as? Bool else {
                    return nil
                }
                
                return UserChallenge(
                    userID: userID,
                    id: record.recordID.recordName,
                    challengeTemplateID: challengeTemplateID,
                    name: name,
                    startDate: startDate,
                    endDate: endDate,
                    startValue: startValue,
                    targetValue: targetValue,
                    field: field,
                    isFailed: isFailed,
                    isActive: isActive
                )
            } ?? []
            
            completion(userChallenges, nil)
        }
    }

    // MARK: - Save User Challenge
    static func saveUserChallenge(userChallenge: UserChallenge, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        
        let challengeRecord = CKRecord(recordType: "UserChallenge")
        challengeRecord["UserID"] = userChallenge.userID as CKRecordValue
        challengeRecord["ChallengeTemplateID"] = userChallenge.challengeTemplateID as CKRecordValue
        challengeRecord["Name"] = userChallenge.name as CKRecordValue
        challengeRecord["StartDate"] = userChallenge.startDate as CKRecordValue
        challengeRecord["EndDate"] = userChallenge.endDate as CKRecordValue
        challengeRecord["StartValue"] = userChallenge.startValue as CKRecordValue
        challengeRecord["TargetValue"] = userChallenge.targetValue as CKRecordValue
        challengeRecord["Field"] = userChallenge.field as CKRecordValue
        challengeRecord["IsFailed"] = userChallenge.isFailed as CKRecordValue
        challengeRecord["IsActive"] = userChallenge.isActive as CKRecordValue
        
        privateDatabase.save(challengeRecord) { savedRecord, error in
            if let error = error {
                print("Error saving user challenge: \(error.localizedDescription)")
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }

    // MARK: - Leave Challenge
    static func leaveChallenge(userID: String, challengeTemplateID: String, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@ AND ChallengeTemplateID == %@", userID, challengeTemplateID)
        let query = CKQuery(recordType: "UserChallenge", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching challenges for deletion: \(error.localizedDescription)")
                completion(false, error)
                return
            }

            guard let record = records?.first else {
                print("No challenge found to leave.")
                completion(false, nil)
                return
            }
            
            privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                if let error = error {
                    print("Error deleting challenge: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Challenge successfully deleted.")
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Update Challenge Progress
    static func updateChallengeProgress(userID: String, field: String, newValue: Int, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@ AND Field == %@", userID, field)
        let query = CKQuery(recordType: "UserChallenge", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching challenges for update: \(error.localizedDescription)")
                completion(false, error)
                return
            }

            guard let record = records?.first else {
                print("No challenge found to update.")
                completion(false, nil)
                return
            }

            let targetValue = record["TargetValue"] as? Int ?? 0
            if newValue >= targetValue {
                record["IsActive"] = false as CKRecordValue
            }

            privateDatabase.save(record) { savedRecord, error in
                if let error = error {
                    print("Error updating challenge: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Challenge progress successfully updated.")
                    completion(true, nil)
                }
            }
        }
    }
}
