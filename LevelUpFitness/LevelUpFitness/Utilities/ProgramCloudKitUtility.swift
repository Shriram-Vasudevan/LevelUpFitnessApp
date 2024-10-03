//
//  ProgramCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/25/24.
//

import CloudKit
import Foundation

class ProgramCloudKitUtility {

    static let customContainer = CKContainer(identifier: "iCloud.LevelUpFitnessCloudKitStorage")

    static func leaveProgram(programID: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Leaving program with ProgramID: \(programID)")
        let privateDatabase = customContainer.privateCloudDatabase
           
        let predicate = NSPredicate(format: "ProgramID == %@", programID)
        let query = CKQuery(recordType: "UserProgramMetadata", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error querying for program metadata: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let record = records?.first else {
                print("No metadata found for program with ID: \(programID)")
                completion(false, nil)
                return
            }

            print("Deleting program metadata with recordID: \(record.recordID.recordName)")
            privateDatabase.delete(withRecordID: record.recordID) { recordID, error in
                if let error = error {
                    print("Error deleting program metadata: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Successfully deleted program metadata with recordID: \(recordID?.recordName ?? "")")
                    completion(true, nil)
                }
            }
        }
    }

    static func uploadNewProgramStatus(programID: String, updatedProgram: Program, completion: @escaping (Bool, Error?) -> Void) {
        print("Uploading new status for ProgramID: \(programID)")
        let privateDatabase = customContainer.privateCloudDatabase
        
        let predicate = NSPredicate(format: "ProgramID == %@", programID)
        let query = CKQuery(recordType: "UserProgramData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error querying for program data: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let record = records?.first else {
                print("No data found for program with ID: \(programID)")
                completion(false, nil)
                return
            }

            print("Converting updated program to JSON")
            let encoder = JSONEncoder()
            if let programData = try? encoder.encode(updatedProgram),
               let tempFileURL = saveDataToTemporaryFile(data: programData) {
                print("Saving updated program data to CKAsset")
                let updatedProgramAsset = CKAsset(fileURL: tempFileURL)
                record["ProgramAsset"] = updatedProgramAsset

                privateDatabase.save(record) { savedRecord, error in
                    if let error = error {
                        print("Error saving updated program data: \(error.localizedDescription)")
                        completion(false, error)
                    } else {
                        print("Successfully saved updated program status")
                        completion(true, nil)
                    }
                }
            } else {
                print("Error encoding program data or saving to temporary file")
                completion(false, nil)
            }
        }
    }

    static func saveDataToTemporaryFile(data: Data) -> URL? {
        print("Saving data to a temporary file")
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        do {
            try data.write(to: fileURL)
            print("Data successfully saved to: \(fileURL.path)")
            return fileURL
        } catch {
            print("Error saving data to temp file: \(error.localizedDescription)")
            return nil
        }
    }

    static func fetchStandardProgramDBRepresentations(completion: @escaping ([StandardProgramDBRepresentation]?, Error?) -> Void) {
        print("Fetching all standard program metadata")
        let publicDatabase = customContainer.publicCloudDatabase
        let query = CKQuery(recordType: "StandardProgramMetadata", predicate: NSPredicate(value: true))
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching standard program metadata: \(error)")
                completion(nil, error)
                return
            }

            print("Query completed. Found \(records?.count ?? 0) records.")
            
            let programs = records?.compactMap { record -> StandardProgramDBRepresentation? in
                guard let id = record["ID"] as? String,
                      let name = record["Name"] as? String,
                      let environment = record["Environment"] as? String,
                      let image = record["Image"] as? String,
                      let description = record["Description"] as? String else {
                    print("Record with missing fields")
                    return nil
                }
                
                print("Fetched program - ID: \(id), Name: \(name)")
                return StandardProgramDBRepresentation(id: id, name: name, environment: environment, image: image, description: description)
            } ?? []
            
            print("Returning \(programs.count) programs")
            completion(programs, nil)
        }
    }

    static func fetchStandardProgramData(programName: String, completion: @escaping (Program?, Error?) -> Void) {
        print("Fetching program data for program name: \(programName)")
        let publicDatabase = customContainer.publicCloudDatabase
        
        let normalizedProgramName = programName.folding(options: .diacriticInsensitive, locale: .current)
        print("Normalized program name: \(normalizedProgramName)")

        let predicate = NSPredicate(format: "Name == %@", normalizedProgramName)
        let query = CKQuery(recordType: "StandardProgramData", predicate: predicate)
        
        publicDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error performing query for program data: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            print("Query completed. Found \(records?.count ?? 0) records.")
            
            guard let record = records?.first else {
                print("No records found for program: \(normalizedProgramName)")
                completion(nil, nil)
                return
            }
            
            print("Record found: \(record.recordID.recordName)")

            guard let programAsset = record["ProgramAsset"] as? CKAsset else {
                print("No ProgramAsset found for program: \(normalizedProgramName)")
                completion(nil, nil)
                return
            }
            
            do {
                print("Attempting to read program data from ProgramAsset...")
                let programData = try Data(contentsOf: programAsset.fileURL!)
                print("Program data read successfully.")
                
                print("Decoding program data...")
                let decoder = JSONDecoder()
                let program = try decoder.decode(Program.self, from: programData)
                print("Program decoded successfully: \(program.programName)")
                
                completion(program, nil)
            } catch {
                print("Error decoding program data: \(error)")
                completion(nil, error)
            }
        }
    }

    static func saveUserProgram(userID: String, program: Program, startDate: String, completion: @escaping (String, Bool, Error?) -> Void) {
        print("Saving user program for UserID: \(userID), ProgramName: \(program.programName)")
        
        let privateDatabase = customContainer.privateCloudDatabase
        let programID = UUID().uuidString

        let programRecord = CKRecord(recordType: "UserProgramData")
        let metadataRecord = CKRecord(recordType: "UserProgramMetadata")

        programRecord["ProgramID"] = programID as CKRecordValue
        programRecord["ProgramName"] = program.programName as CKRecordValue
        
        let encoder = JSONEncoder()

        do {
            let programData = try encoder.encode(program)
            

            if let tempFileURL = saveDataToTemporaryFile(data: programData) {
                let programAsset = CKAsset(fileURL: tempFileURL)
                programRecord["ProgramAsset"] = programAsset
            }
        } catch {
            print("Error encoding program: \(error.localizedDescription)")
            completion(programID, false, error)
            return
        }

        metadataRecord["UserID"] = userID as CKRecordValue
        metadataRecord["Program"] = program.programName as CKRecordValue
        metadataRecord["StartDate"] = startDate as CKRecordValue
        metadataRecord["ProgramID"] = programID as CKRecordValue

        privateDatabase.save(programRecord) { savedProgramRecord, error in
            if let error = error {
                print("Error saving program data: \(error.localizedDescription)")
                completion(programID, false, error)
                return
            }
            print("Successfully saved program data")

            privateDatabase.save(metadataRecord) { savedMetadataRecord, error in
                if let error = error {
                    print("Error saving program metadata: \(error.localizedDescription)")
                    completion(programID, false, error)
                    return
                }
                print("Successfully saved program metadata")
                completion(programID, true, nil)
            }
        }
    }


    static func fetchUserActivePrograms(userID: String) async throws -> [UserProgramDBRepresentation] {
        print("Fetching user active programs for UserID: \(userID)")
        
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "UserID == %@", userID)
        let query = CKQuery(recordType: "UserProgramMetadata", predicate: predicate)

        let (matchResults, _) = try await privateDatabase.records(matching: query)

        let activePrograms: [UserProgramDBRepresentation] = matchResults.compactMap { recordID, result in
            switch result {
            case .success(let record):
                guard let userID = record["UserID"] as? String,
                      let program = record["Program"] as? String,
                      let startDate = record["StartDate"] as? String,
                      let programID = record["ProgramID"] as? String else {
                    print("Record with missing fields: \(recordID)")
                    return nil
                }

                if let expirationDate = DateUtility.getDateNWeeksAfterDate(dateString: startDate, weeks: 4),
                   let expirationDateObj = DateFormatter().date(from: expirationDate),
                   expirationDateObj < Date() {
                    print("Program \(programID) has expired. Leaving the program.")

                    leaveProgram(programID: programID) { success, error in
                        if success {
                            print("Successfully left program \(programID)")
                        } else {
                            print("Failed to leave program \(programID): \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }

                    return nil
                }
                
                print("Fetched active program - ProgramID: \(programID), ProgramName: \(program)")
                return UserProgramDBRepresentation(userID: userID, program: program, startDate: startDate, programID: programID)
                
            case .failure(let error):
                print("Failed to fetch record for \(recordID), error: \(error.localizedDescription)")
                return nil
            }
        }
        
        print("Returning \(activePrograms.count) active programs")
        return activePrograms
    }


    static func fetchUserProgramData(programID: String, completion: @escaping (ProgramWithID?, Error?) -> Void) {
        print("Fetching user program data for ProgramID: \(programID)")
        let privateDatabase = customContainer.privateCloudDatabase
        let predicate = NSPredicate(format: "ProgramID == %@", programID)
        let query = CKQuery(recordType: "UserProgramData", predicate: predicate)
        
        privateDatabase.perform(query, inZoneWith: nil) { records, error in
            if let error = error {
                print("Error fetching program data: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            print("Query completed. Found \(records?.count ?? 0) records.")
            
            guard let record = records?.first, let programAsset = record["ProgramAsset"] as? CKAsset else {
                print("No program asset found for ProgramID: \(programID)")
                completion(nil, nil)
                return
            }
            
            do {
                print("Attempting to read program data from ProgramAsset...")
                let programData = try Data(contentsOf: programAsset.fileURL!)
                print("Program data read successfully.")
                
                print("Decoding program data...")
                let decoder = JSONDecoder()
                let program = try decoder.decode(Program.self, from: programData)
                print("Program decoded successfully: \(program.programName)")
                
                let programWithID = ProgramWithID(programID: programID, program: program)
                completion(programWithID, nil)
            } catch {
                print("Error decoding program data: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
}
