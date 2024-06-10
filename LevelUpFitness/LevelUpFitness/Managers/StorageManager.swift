//
//  StorageManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/20/24.
//

import Foundation
import Amplify

@MainActor
class StorageManager: ObservableObject {
    @Published var dailyVideo: URL?
    @Published var program: Program?
    @Published var standardProgramNames: [String]?
    @Published var retrievingProgram: Bool = false
    
    
    func downloadDailyVideo() async {
        do {
            let downloadTask = Amplify.Storage.downloadData(key: "DailyVideo/Video.mp4")
//            for await progress in await downloadTask.progress {
////                print(progress)
//            }
            let data = try await downloadTask.value
            
            if let url = saveVideoLocally(at: "DailyVideo", video: data) {
                self.dailyVideo = url
            }
        }
        catch {
            print(error)
        }
    }
    
    func saveVideoLocally(at path: String, video: Data) -> URL? {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let videoURL = temporaryDirectory.appendingPathComponent(path).appendingPathExtension("mp4")
        
        do {
            try video.write(to: videoURL, options: .atomic)
            return videoURL
        } catch {
            print(error)
            return nil
        }
    }
    
    func getUserProgram() async  {
        do {
            retrievingProgram = true
            let userID = try await Amplify.Auth.getCurrentUser().userId
            if let date = getPreviousMondayDate() {
                let downloadTask = Amplify.Storage.downloadData(key: "UserPrograms/\(userID)/(\(date)).json")

                let data = try await downloadTask.value
                
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(Program.self, from: data)
                
                print(decodedData)
                
                self.program = decodedData
            }
            self.retrievingProgram = false
            
        } catch {
            print("user program retrieval error: \(error)")
            self.retrievingProgram = false
            
            if let programName = await getUserProgramDBRepresentation() {
                await joinStandardProgram(programName: programName)
            }
            else {
                await getStandardProgramNames()
            }
        }
    }
    
    func getUserProgramDBRepresentation() async -> String? {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserProgramInfo", queryParameters: ["UserID" : userID])
            let response = try await Amplify.API.get(request: request)
            
//            let jsonString = String(data: response, encoding: .utf8)
            
            let jsonDecoder = JSONDecoder()
            let programDBRepresentation = try jsonDecoder.decode(ProgramDBRepresentation.self, from: response)
            
            return programDBRepresentation.program
        } catch {
            print(error)
            return nil
        }
    }

    
    func getStandardProgramNames() async {
        do {
            let restRequest = RESTRequest(apiName: "LevelUpFitnessS3AccessAPI", path: "/getStandardProgramNames")
            let response = try await Amplify.API.get(request: restRequest)
            
            let jsonString = String(data: response, encoding: .utf8)
            
            if let array = try JSONSerialization.jsonObject(with: response) as? [String] {
                self.standardProgramNames = array.map( { String($0.dropLast(5)) })
            } else {
                print("Error getting names")
            }
            
        } catch {
            print(error)
        }
    }
    
    func joinStandardProgram(programName: String) async {
        do {
            print("StandardPrograms/\(programName).json")
            let downloadTask = Amplify.Storage.downloadData(key: "StandardPrograms/\(programName).json")
            
            let data = try await downloadTask.value
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Program.self, from: data)
            
            await temporarilySaveStandardProgram(programName: programName, data: data) { success, url in
                if success, let fileURL = url {
                    await self.uploadStandardProgram(fileURL: fileURL, programName: programName) { success in
                        if success {
                            self.program = decodedData
                        }
                    }
                }
            }
            
        } catch {
            print(error)
        }
    }
    
    func temporarilySaveStandardProgram(programName: String, data: Data, completionHandler: @escaping (Bool, URL?) async -> Void) async {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent(programName).appendingPathExtension("json")
        do {
            try data.write(to: fileURL, options: .atomic)
            await completionHandler(true, fileURL)
        } catch {
            print(error)
            await completionHandler(false, nil)
        }
    }
    
    func uploadStandardProgram(fileURL: URL, programName: String, completionHandler: @escaping (Bool) -> Void) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if let date = getPreviousMondayDate() {
                let storageOperation = Amplify.Storage.uploadFile(key: "UserPrograms/\(userID)/(\(date)).json", local: fileURL)
                    
                let progress = try await storageOperation.value
                print("Upload completed: \(progress)")
                
                try await addProgramToDB(programName: programName)
                
                completionHandler(true)
            } else {
                print("Failed to get date")
                completionHandler(false)
            }
        } catch {
            print("Upload failed with error: \(error)")
            completionHandler(false)
        }
    }
    
    func addProgramToDB(programName: String) async throws {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/addUserProgram", queryParameters: ["UserID" : userID, "Program" : programName])
            let response = try await Amplify.API.put(request: request)
        } catch {
            print(error)
            throw APIError.failed
        }
    }
    
    
    func uploadNewProgramStatus(completionHandler: @escaping () -> Void) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            print(userID)
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(program)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString)
            
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let fileURL = temporaryDirectory.appendingPathComponent("\(userID).json")
            
            try jsonData.write(to: fileURL)
            
            let storageOperation = Amplify.Storage.uploadFile(key: "UserPrograms/\(userID).json", local: fileURL)
                    
            do {
                let progress = try await storageOperation.value
                print("Upload completed: \(progress)")
                DispatchQueue.main.async {
                    completionHandler()
                }
            } catch {
                print("Upload failed with error: \(error)")
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getPreviousMondayDate() -> String? {
        let calendar = Calendar.current
        
        let weekdayComponent = calendar.component(.weekday, from: Date())
        let dayToSubtract = (weekdayComponent == 1 ? 6 : weekdayComponent - 2)
        
        if let previousMonday = calendar.date(byAdding: .day, value: -dayToSubtract, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            return dateFormatter.string(from: previousMonday)
        }
        else {
            return nil
        }
    }

}

enum APIError: Error {
    case failed
}
