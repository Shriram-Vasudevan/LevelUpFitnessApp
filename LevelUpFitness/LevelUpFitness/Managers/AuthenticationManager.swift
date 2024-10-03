//
//  AuthenticationManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/20/24.
//

import SwiftUI

import CloudKit
import SwiftUI

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()

    @Published var username: String?
    @Published var name: String?
    @Published var pfp: Data?

    private let privateDB = CKContainer(identifier: "iCloud.LevelUpFitnessCloudKitStorage").privateCloudDatabase

    enum RecordType: String {
        case User = "User"
    }
    
    func signOut(completion: @escaping (Bool) -> Void) {
        self.username = nil
        self.name = nil
        self.pfp = nil

        UserDefaults.standard.removeObject(forKey: "username-key")
        UserDefaults.standard.removeObject(forKey: "name-key")

        print("User signed out. Local data cleared.")
        completion(true)
    }

    func deleteUserData(completion: @escaping (Bool, Error?) -> Void) {
        let privateDB = CKContainer.default().privateCloudDatabase
        let recordTypes = ["UserRecord", "UserProgramData", "UserChallenge", "WeightTrendData", "LevelTrendData", "XPData"]
        
        let dispatchGroup = DispatchGroup()
        var deletionError: Error?
        
        for recordType in recordTypes {
            dispatchGroup.enter()

            let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
            
            privateDB.perform(query, inZoneWith: nil) { (records, error) in
                if let error = error {
                    deletionError = error
                    dispatchGroup.leave()
                    return
                }
                
                guard let records = records else {
                    dispatchGroup.leave()
                    return
                }

                let recordIDs = records.map { $0.recordID }
                let deleteOperation = CKModifyRecordsOperation(recordIDsToDelete: recordIDs)
                deleteOperation.modifyRecordsCompletionBlock = { _, deletedRecordIDs, deleteError in
                    if let deleteError = deleteError {
                        deletionError = deleteError
                    }
                    dispatchGroup.leave()
                }

                privateDB.add(deleteOperation)
            }
        }

        dispatchGroup.notify(queue: DispatchQueue.main) {
            if let error = deletionError {
                print("Failed to delete some or all data: \(error.localizedDescription)")
                completion(false, error)
            } else {
                UserDefaults.standard.removeObject(forKey: "username-key")
                UserDefaults.standard.removeObject(forKey: "name-key")
                print("All user data deleted successfully from iCloud and locally.")
                completion(true, nil)
            }
        }
    }


    
    func saveOrUpdateUserData(username: String?, name: String?, pfp: Data?, completion: @escaping (Bool, Error?) -> Void) {
        let userRecordID = CKRecord.ID(recordName: "UserRecord")
        privateDB.fetch(withRecordID: userRecordID) { (existingRecord, fetchError) in
            DispatchQueue.main.async {
                if let fetchError = fetchError as? CKError {
                    if fetchError.code == .unknownItem {
                        let newUserRecord = CKRecord(recordType: RecordType.User.rawValue, recordID: userRecordID)
                        self.configureUserRecord(newUserRecord, username: username, name: name, pfp: pfp)
                        self.saveRecord(newUserRecord, completion: completion)
                    } else {
                        print("Error fetching record: \(fetchError.localizedDescription)")
                        completion(false, fetchError)
                    }
                } else if let existingRecord = existingRecord {
                    self.configureUserRecord(existingRecord, username: username, name: name, pfp: pfp)
                    self.saveRecord(existingRecord, completion: completion)
                }
            }
        }
    }

    private func configureUserRecord(_ userRecord: CKRecord, username: String?, name: String?, pfp: Data?) {
        if let username = username {
            userRecord["username"] = username
            self.username = username
        }
        
        if let name = name {
            userRecord["name"] = name
            self.name = name
        }
        
        if let pfp = pfp {
            let imageFileURL = self.saveProfilePictureLocally(pfp: pfp)
            let imageAsset = CKAsset(fileURL: imageFileURL)
            userRecord["profilePicture"] = imageAsset
            self.pfp = pfp
        }
    }

    private func saveRecord(_ userRecord: CKRecord, completion: @escaping (Bool, Error?) -> Void) {
        privateDB.save(userRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error saving/updating user data: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("User data saved/updated successfully.")
                    completion(true, nil)
                }
            }
        }
    }


    func getUserData(completion: @escaping (Bool, Error?) -> Void) {
        let userRecordID = CKRecord.ID(recordName: "UserRecord")
        privateDB.fetch(withRecordID: userRecordID) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    completion(false, error)
                } else if let record = record {
                    self.username = record["username"] as? String
                    self.name = record["name"] as? String

                    if let profilePictureAsset = record["profilePicture"] as? CKAsset,
                       let imageData = try? Data(contentsOf: profilePictureAsset.fileURL!) {
                        self.pfp = imageData
                    }

                    print("User data retrieved successfully.")
                    completion(true, nil)
                }
            }
        }
    }

    // MARK: - Delete Profile Picture
    func removeProfilePicture(completion: @escaping (Bool, Error?) -> Void) {
        let userRecordID = CKRecord.ID(recordName: "UserRecord")
        privateDB.fetch(withRecordID: userRecordID) { (record, error) in
            DispatchQueue.main.async {
                if let record = record {
                    record["profilePicture"] = nil
                    self.privateDB.save(record) { (savedRecord, error) in
                        if let error = error {
                            print("Error deleting profile picture: \(error.localizedDescription)")
                            completion(false, error)
                        } else {
                            self.pfp = nil
                            print("Profile picture deleted successfully.")
                            completion(true, nil)
                        }
                    }
                } else if let error = error {
                    print("Error fetching record for deletion: \(error.localizedDescription)")
                    completion(false, error)
                }
            }
        }
    }

    private func saveProfilePictureLocally(pfp: Data) -> URL {
        let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pfpUrl = directoryUrl.appendingPathComponent("pfp-\(UUID().uuidString).png")
        
        try? pfp.write(to: pfpUrl)
        return pfpUrl
    }
}
