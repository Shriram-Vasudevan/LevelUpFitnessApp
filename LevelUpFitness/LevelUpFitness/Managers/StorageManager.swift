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
            guard let userID = try? await Amplify.Auth.getCurrentUser().userId else { return }
            
            let downloadTask = Amplify.Storage.downloadData(key: "UserPrograms/\(userID).json")
//            for await progress in await downloadTask.progress {
////                print(progress)
//            }
            let data = try await downloadTask.value
            
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Program.self, from: data)
            
            print(decodedData)
            
            self.program = decodedData
            self.retrievingProgram = false
            
        } catch {
            print("user program retrieval error: \(error)")
            self.retrievingProgram = false
            await getStandardProgramNames()
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
                    await self.uploadStandardProgram(fileURL: fileURL) { success in
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
    
    func uploadStandardProgram(fileURL: URL, completionHandler: @escaping (Bool) -> Void) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let storageOperation = Amplify.Storage.uploadFile(key: "UserPrograms/\(userID).json", local: fileURL)
                
            let progress = try await storageOperation.value
            print("Upload completed: \(progress)")
            completionHandler(true)
        } catch {
            print("Upload failed with error: \(error)")
            completionHandler(false)
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

}
