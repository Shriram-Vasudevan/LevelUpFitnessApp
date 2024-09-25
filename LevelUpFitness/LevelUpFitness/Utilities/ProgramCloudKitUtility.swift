//
//  ProgramCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/25/24.
//

import Foundation

import CloudKit


class ProgramCloudKitUtility {
    static func fetchStandardProgramDBRepresentations(completion: @escaping ([StandardProgramDBRepresentation]?, Error?) -> Void) {
        let publicDatabase = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "StandardProgram", predicate: NSPredicate(value: true))  // Fetch all records
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else {
                completion(nil, error)
                return
            }
            
            let standardPrograms = records.compactMap { record -> StandardProgramDBRepresentation? in
                return recordToStandardProgramDBRepresentation(record: record)
            }
            
            completion(standardPrograms, nil)
        }
    }
        
    static func fetchStandardProgramData(programName: String, completion: @escaping (Program?, Error?) -> Void) {
            let publicDatabase = CKContainer.default().publicCloudDatabase
            let query = CKQuery(recordType: "StandardProgramData", predicate: NSPredicate(format: "Name == %@", programName))
            
            publicDatabase.perform(query, inZoneWith: nil) { records, error in
                guard let record = records?.first, let programData = record["ProgramData"] as? Data else {
                    completion(nil, error)
                    return
                }
                
                let decoder = JSONDecoder()
                if let program = try? decoder.decode(Program.self, from: programData) {
                    completion(program, nil)
                } else {
                    completion(nil, error)
                }
            }
        }
    
    static func fetchUserPrograms(completion: @escaping ([Program]?, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "UserProgram", predicate: NSPredicate(value: true))
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let records = records else {
                completion(nil, error)
                return
            }
            
            let programs = records.compactMap { record -> Program? in
                return recordToProgram(record: record)
            }
            
            completion(programs, nil)
        }
    }

    static func saveProgram(program: Program, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let record = CKRecord(recordType: "UserProgram")
        
        record["programName"] = program.programName as CKRecordValue
        record["programDuration"] = program.programDuration as CKRecordValue
        record["startDate"] = program.startDate as CKRecordValue
        record["startWeekday"] = program.startWeekday as CKRecordValue
        record["environment"] = program.environment as CKRecordValue
        
        let encoder = JSONEncoder()
        if let programData = try? encoder.encode(program.program) {
            record["workout_schedule"] = programData as CKRecordValue
        }
        
        privateDatabase.save(record) { savedRecord, error in
            if let _ = savedRecord {
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
    static func deleteProgram(programName: String, completion: @escaping (Bool, Error?) -> Void) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        let query = CKQuery(recordType: "UserProgram", predicate: NSPredicate(format: "programName == %@", programName))
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            guard let record = records?.first else {
                completion(false, error)
                return
            }
            
            privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                if let _ = recordID {
                    completion(true, nil)
                } else {
                    completion(false, error)
                }
            }
        }
    }

    static func recordToProgram(record: CKRecord) -> Program? {
        guard let programName = record["programName"] as? String,
              let programDuration = record["programDuration"] as? Int,
              let startDate = record["startDate"] as? String,
              let startWeekday = record["startWeekday"] as? String,
              let environment = record["environment"] as? String else {
            return nil
        }
        
        var programDays: [ProgramDay] = []
        
        if let programData = record["workout_schedule"] as? Data {
            let decoder = JSONDecoder()
            programDays = (try? decoder.decode([ProgramDay].self, from: programData)) ?? []
        }
        
        return Program(program: programDays, programName: programName, programDuration: programDuration, startDate: startDate, startWeekday: startWeekday, environment: environment)
    }
    
    static func recordToStandardProgramDBRepresentation(record: CKRecord) -> StandardProgramDBRepresentation? {
        guard let id = record["ID"] as? String,
              let name = record["Name"] as? String,
              let environment = record["Environment"] as? String else {
            return nil
        }
        
        return StandardProgramDBRepresentation(id: id, name: name, environment: environment)
    }
}
