//
//  ProgramCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/25/24.
//

import CloudKit
import Foundation

class ProgramCloudKitUtility {

    static func leaveProgram(programID: String, completion: @escaping (Bool, Error?) -> Void) {
           let privateDatabase = CKContainer.default().privateCloudDatabase
           
           let predicate = NSPredicate(format: "ProgramID == %@", programID)
           let query = CKQuery(recordType: "UserProgramMetadata", predicate: predicate)
           
           privateDatabase.perform(query, inZoneWith: nil) { records, error in
               guard let record = records?.first else {
                   completion(false, error)
                   return
               }
    
               privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                   if let error = error {
                       completion(false, error)
                   } else {
                       completion(true, nil)
                   }
               }
           }
       }

    static func uploadNewProgramStatus(programID: String, updatedProgram: Program, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let predicate = NSPredicate(format: "ProgramID == %@", programID)
        let query = CKQuery(recordType: "UserProgramData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let record = records?.first else {
                completion(false, error)
                return
            }

            let encoder = JSONEncoder()
            if let programData = try? encoder.encode(updatedProgram),
               let tempFileURL = saveDataToTemporaryFile(data: programData) {
                let updatedProgramAsset = CKAsset(fileURL: tempFileURL)
                
                record["ProgramAsset"] = updatedProgramAsset

                privateDatabase.save(record) { savedRecord, error in
                    if let error = error {
                        completion(false, error)
                    } else {
                        completion(true, nil)
                    }
                }
            } else {
                completion(false, nil)
            }
        }
    }
    
    static func saveDataToTemporaryFile(data: Data) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving temp file: \(error.localizedDescription)")
            return nil
        }
    }
    
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
            guard let record = records?.first, let programAsset = record["ProgramAsset"] as? CKAsset else {
                completion(nil, error)
                return
            }
            
            do {
                let programData = try Data(contentsOf: programAsset.fileURL!)
                let decoder = JSONDecoder()
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
        programRecord["ProgramName"] = program.programName as CKRecordValue
        
        let encoder = JSONEncoder()
        if let programData = try? encoder.encode(program.program),
           let tempFileURL = saveDataToTemporaryFile(data: programData) {
            let programAsset = CKAsset(fileURL: tempFileURL)
            programRecord["ProgramAsset"] = programAsset
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

    static func fetchUserProgramData(programID: String, completion: @escaping (ProgramWithID?, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let predicate = NSPredicate(format: "ProgramID == %@", programID)
        let query = CKQuery(recordType: "UserProgramData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let record = records?.first, let programAsset = record["ProgramAsset"] as? CKAsset else {
                completion(nil, error)
                return
            }
            
            do {
                let programData = try Data(contentsOf: programAsset.fileURL!)
                let decoder = JSONDecoder()
                let program = try decoder.decode(Program.self, from: programData)
                let programWithID = ProgramWithID(programID: programID, program: program)
                completion(programWithID, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}

