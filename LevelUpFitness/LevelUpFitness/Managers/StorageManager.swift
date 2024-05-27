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
        } catch {
            print(error)
        }
    }
}
