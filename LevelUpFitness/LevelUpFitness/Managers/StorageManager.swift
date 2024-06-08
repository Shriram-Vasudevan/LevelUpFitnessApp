//
//  StorageManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/20/24.
//

import Foundation
import Amplify

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
                DispatchQueue.main.async {
                    self.dailyVideo = url
                }
            }
        }
        catch {
            print(error)
        }
    }
    
    func saveVideoLocally(at path: String, video: Data) -> URL? {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let videoURL = temporaryDirectory.appendingPathComponent("path").appendingPathExtension("mp4")
        
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
            
            DispatchQueue.main.async {
                self.program = decodedData
            }
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
            
            print("standard programs \(jsonString)")
            
        } catch {
            print(error)
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
                    
            Task {
                do {
                    let progress = try await storageOperation.value
                    print("Upload completed: \(progress)")
                    DispatchQueue.main.async {
                        completionHandler()
                    }
                } catch {
                    print("Upload failed with error: \(error)")
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }

}
