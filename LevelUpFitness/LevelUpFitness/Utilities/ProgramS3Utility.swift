//
//  ProgramS3Utility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation
import Amplify

class ProgramS3Utility {
    static func getStandardProgramNames() async -> [String]? {
        do {
            let restRequest = RESTRequest(apiName: "LevelUpFitnessS3AccessAPI", path: "/getStandardProgramNames")
            let response = try await Amplify.API.get(request: restRequest)
            
            let jsonString = String(data: response, encoding: .utf8)
            
            if let array = try JSONSerialization.jsonObject(with: response) as? [String] {
                return array.map( { String($0.dropLast(5)) })
            } else {
                print("Error getting names")
                return nil
            }
            
        } catch {
            print(error)
            return nil
        }
    }
    
    static func getUserProgramNames() async -> [String]? {
        do {
            let restRequest = RESTRequest(apiName: "LevelUpFitnessS3AccessAPI", path: "/getUserProgramNames")
            let response = try await Amplify.API.get(request: restRequest)
            
            let jsonString = String(data: response, encoding: .utf8)
            
            print(jsonString)
            
            if let array = try JSONSerialization.jsonObject(with: response) as? [String] {
                return array.map({ String($0.dropLast(5))})
            } else {
                print("Error getting names")
                return nil
            }
        } catch {
            print(error)
            return nil
        }
    }
    
    static func joinStandardProgram(programName: String, badgeManager: BadgeManager, completion: @escaping (Result<Program, Error>) -> Void) async {
        do {
            print("StandardPrograms/\(programName).json")
            let downloadTask = Amplify.Storage.downloadData(key: "StandardPrograms/\(programName).json")
            
            let data = try await downloadTask.value
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Program.self, from: data)

            await LocalStorageUtility.temporarilySaveStandardProgram(programName: programName, data: data) { success, url in
                if success, let fileURL = url {
                    await self.uploadStandardProgram(fileURL: fileURL, programName: programName, badgeManager: badgeManager) { success in
                        if success {
                            completion(.success(decodedData))
                        }
                    }
                }
            }
            
        } catch {
            print(error)
            completion(.failure(GeneralError.failed))
        }
    }
    
    static func leaveProgram(programName: String) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessS3AccessAPI", path: "/leaveProgram", queryParameters: ["UserID" : userID, "ProgramName" : programName])
            
            let response = try await Amplify.API.delete(request: request)
            
            print(String(data: response, encoding: .utf8))
        } catch {
            print(error)
        }
    }
    
    static func uploadStandardProgram(fileURL: URL, programName: String, badgeManager: BadgeManager, completion: @escaping (Bool) -> Void) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if let date = DateUtility.getPreviousMondayDate() {
                let storageOperation = Amplify.Storage.uploadFile(key: "UserPrograms/\(userID)/\(programName)/(\(date)).json", local: fileURL)
                
                let progress = try await storageOperation.value
                print("Upload completed: \(progress)")
                
                try await ProgramDynamoDBUtility.addProgramToDB(programName: programName)
                
                await badgeManager.checkIfBadgesEarned(weeksUpdated: true)
                completion(true)
            } else {
                print("Failed to get date")
                completion(false)
            }
        } catch {
            print("Upload failed with error: \(error)")
            completion(false)
        }
    }
    
    
    static func uploadNewProgramStatus(program: Program, completionHandler: @escaping () -> Void) async throws  {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if let date = DateUtility.getPreviousMondayDate() {
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(program)
                let jsonString = String(data: jsonData, encoding: .utf8)
                
                try LocalStorageUtility.cacheUserProgram(userID: userID, programName: program.programName, date: date, program: program)
                
                if let url = LocalStorageUtility.getUserProgramFileURL(userID: userID, programName: program.programName, date: date) {
                    let storageOperation = Amplify.Storage.uploadFile(key: "UserPrograms/\(userID)/\(program.programName)/(\(date)).json", local: url)
                            
                    let progress = try await storageOperation.value
                    completionHandler()
                }
            }
        } catch {
            print(error.localizedDescription)
            throw GeneralError.failed
        }
    }
}
