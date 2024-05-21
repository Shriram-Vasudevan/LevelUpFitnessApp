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
    
    func downloadDailyVideo() async {
        do {
            let downloadTask = Amplify.Storage.downloadData(key: "DailyVideo/Running.mp4")
            for await progress in await downloadTask.progress {
                print(progress)
            }
            let data = try await downloadTask.value
            
            if let url = saveVideoLocally(at: "DailyVideo", video: data) {
                DispatchQueue.main.async {
                    dailyVideo = url
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func saveVideoLocally(at path: String, video: Data) -> URL? {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        guard let videoURL = temporaryDirectory.appendingPathComponent("path").appendingPathExtension("mp4") else { return }
        
        do {
            try video.write(to: videoURL, options: .atomic)
            return videoURL
        } catch {
            print(error.localizedDescription)
        }
    }
}
