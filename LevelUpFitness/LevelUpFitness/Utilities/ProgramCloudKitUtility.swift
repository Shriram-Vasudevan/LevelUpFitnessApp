//
//  ProgramCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/25/24.
//

import CloudKit
import Foundation

class ProgramCloudKitUtility {
    static func fetchStandardProgramDBRepresentations(completion: @escaping ([StandardProgramDBRepresentation]?, Error?) -> Void) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "StandardProgramMetadata", predicate: NSPredicate(value: true)) 
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else {
                completion(nil, error)
                return
            }
            
            let programs = records.compactMap { record -> StandardProgramDBRepresentation? in
                guard let id = record["ID"] as? String,
                      let name = record["Name"] as? String,
                      let environment = record["Environment"] as? String else {
                    return nil
                }
                
                return StandardProgramDBRepresentation(id: id, name: name, environment: environment)
            }
            
            completion(programs, nil)
        }
    }

    static func fetchStandardProgramData(programName: String, completion: @escaping (Program?, Error?) -> Void) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(format: "Name == %@", programName)
        let query = CKQuery(recordType: "StandardProgramData", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let record = records?.first, let programData = record["programData"] as? Data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let program = try decoder.decode(Program.self, from: programData)
                completion(program, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    static func saveUserProgram(userID: String, program: Program, startDate: String, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let programID = UUID().uuidString

        let programRecord = CKRecord(recordType: "UserProgramData")
        let metadataRecord = CKRecord(recordType: "UserProgramMetadata")

        programRecord["ProgramID"] = programID as CKRecordValue
        programRecord["programName"] = program.programName as CKRecordValue
        programRecord["startDate"] = startDate as CKRecordValue
        
        let encoder = JSONEncoder()
        if let programData = try? encoder.encode(program.program) {
            programRecord["workout_schedule"] = programData as CKRecordValue
        }
        
        metadataRecord["UserID"] = userID as CKRecordValue
        metadataRecord["Program"] = program.programName as CKRecordValue
        metadataRecord["StartDate"] = startDate as CKRecordValue
        metadataRecord["ProgramID"] = programID as CKRecordValue
        

        privateDatabase.save(programRecord) { programSavedRecord, error in
            if let error = error {
                completion(false, error)
                return
            }
            privateDatabase.save(metadataRecord) { metadataSavedRecord, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                completion(true, nil)
            }
        }
    }

    static func fetchUserActivePrograms(userID: String, completion: @escaping ([UserProgramDBRepresentation]?, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@", userID)
        let query = CKQuery(recordType: "UserProgramMetadata", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else {
                completion(nil, error)
                return
            }
            
            let activePrograms = records.compactMap { record -> UserProgramDBRepresentation? in
                guard let userID = record["UserID"] as? String,
                      let program = record["Program"] as? String,
                      let startDate = record["StartDate"] as? String,
                      let programID = record["ProgramID"] as? String else {
                    return nil
                }
                
                return UserProgramDBRepresentation(userID: userID, program: program, startDate: startDate, programID: programID)
            }
            
            completion(activePrograms, nil)
        }
    }

    static func fetchUserProgramData(programID: String, completion: @escaping (Program?, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(format: "ProgramID == %@", programID)
        let query = CKQuery(recordType: "UserProgramData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let record = records?.first, let programData = record["workout_schedule"] as? Data else {
                completion(nil, error)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let program = try decoder.decode(Program.self, from: programData)
                completion(program, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
