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
        // Clear local user data
        self.username = nil
        self.name = nil
        self.pfp = nil

        // Optionally clear UserDefaults if you're caching user data
        UserDefaults.standard.removeObject(forKey: "username-key")
        UserDefaults.standard.removeObject(forKey: "name-key")

        print("User signed out. Local data cleared.")
        completion(true)
    }

    func deleteUserData(completion: @escaping (Bool, Error?) -> Void) {
        let userRecordID = CKRecord.ID(recordName: "currentUser")  // Unique identifier for the user

        // Delete the record from CloudKit
        privateDB.delete(withRecordID: userRecordID) { (recordID, error) in
            DispatchQueue.main.async {
                if let error = error {
                    print("Failed to delete user data: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    // Clear local user data as well
                    self.username = nil
                    self.name = nil
                    self.pfp = nil
                    
                    // Optionally clear any cached data in UserDefaults
                    UserDefaults.standard.removeObject(forKey: "username-key")
                    UserDefaults.standard.removeObject(forKey: "name-key")
                    
                    print("User data deleted successfully from iCloud and locally.")
                    completion(true, nil)
                }
            }
        }
    }

    
    func saveOrUpdateUserData(username: String?, name: String?, pfp: Data?, completion: @escaping (Bool, Error?) -> Void) {
        let userRecordID = CKRecord.ID(recordName: "currentUser")  
        let userRecord = CKRecord(recordType: RecordType.User.rawValue, recordID: userRecordID)

        if let username = username {
            userRecord["username"] = username
        }
        
        if let name = name {
            userRecord["name"] = name
        }
        
        if let pfp = pfp {
            let imageFileURL = self.saveProfilePictureLocally(pfp: pfp)
            let imageAsset = CKAsset(fileURL: imageFileURL)
            userRecord["profilePicture"] = imageAsset
        }

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
        let userRecordID = CKRecord.ID(recordName: "currentUser")
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
        let userRecordID = CKRecord.ID(recordName: "currentUser")
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
