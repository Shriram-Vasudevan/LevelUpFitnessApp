//
//  LocalStorageUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

class LocalStorageUtility {
    static func appendDataToDocumentsDirectoryFile(at path: String, data: Data) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        
        guard let newlineData = "\n".data(using: .utf8) else {
            print("Failed to encode the newline character as UTF-8 data.")
            return
        }
        
        do {
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                try fileHandle.seekToEnd()
                fileHandle.write(data)
                fileHandle.write(newlineData)
                try fileHandle.close()
            } else {
                try data.write(to: fileURL)
                try "\n".write(to: fileURL, atomically: true, encoding: .utf8)
            }
        } catch {
            print(error)
        }
    }
    
    static func readDocumentsDirectoryJSONStringFile(at path: String) -> String? {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        do {
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            return fileContent
        } catch {
            print(error)
            return nil
        }
    }
    
    static func temporarilySaveStandardProgram(programName: String, data: Data, completionHandler: @escaping (Bool, URL?) async -> Void) async {
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
    
    
    
    static func getUserProgramFileURL(userID: String, programName: String, date: String) -> URL? {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectoryURL.appendingPathComponent("Programs/\(userID)/\(programName)/\(date).json")
    }

    static func userProgramSaved(userID: String, programName: String, date: String) -> Bool {
        print("checking save")
        guard let fileURL = getUserProgramFileURL(userID: userID, programName: programName, date: date) else { return false }
        
        print("save \(FileManager.default.fileExists(atPath: fileURL.path))")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    static func cacheUserProgram(userID: String, programName: String, date: String, program: Program) throws {
        print("Attempting to cache")
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let programsDirectoryURL = documentsDirectoryURL.appendingPathComponent("Programs")
        let userProgramsDirectoryURL = programsDirectoryURL.appendingPathComponent(userID)
        let specificUserProgramDirectory = userProgramsDirectoryURL.appendingPathComponent(programName)
        let fileURL = specificUserProgramDirectory.appendingPathComponent("\(date).json")
        
        print("the path " + fileURL.path)
        
        do {
            if !FileManager.default.fileExists(atPath: programsDirectoryURL.path) {
                try FileManager.default.createDirectory(at: programsDirectoryURL, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: userProgramsDirectoryURL.path) {
                try FileManager.default.createDirectory(at: userProgramsDirectoryURL, withIntermediateDirectories: true)
            }
            
            if !FileManager.default.fileExists(atPath: specificUserProgramDirectory.path) {
                try FileManager.default.createDirectory(at: specificUserProgramDirectory, withIntermediateDirectories: true)
            }
            
            let jsonEncoder = JSONEncoder()
            let data = try jsonEncoder.encode(program)
            
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to cache: \(error)")
            throw FileError.failed
        }
    }
    
    static func saveExerciseToFile(exercise: ExerciseLibraryExercise, cdnURL: URL, completion: @escaping (Result<ExerciseLibraryExerciseDownloaded, Error>) -> Void)
    {
        do {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let exerciseDirectory = documentsDirectory.appendingPathComponent("Exercises", isDirectory: true)
            let fileURL = exerciseDirectory.appendingPathComponent("\(exercise.name)-\(exercise.id).mp4")
            
            if !FileManager.default.fileExists(atPath: exerciseDirectory.path) {
                try FileManager.default.createDirectory(at: exerciseDirectory, withIntermediateDirectories: true)
            }
            
            let task = URLSession.shared.downloadTask(with: cdnURL) { (location, response, error) in
                guard let location = location, error == nil else {
                    print("Failed to download video: \(error?.localizedDescription ?? "Unknown error")")
                    completion(.failure(error ?? FileError.failed))
                    return
                }
                
                print("The response: \(String(describing: response))")
                
                do {
                    try FileManager.default.moveItem(at: location, to: fileURL)
                    let downloadedExercise = ExerciseLibraryExerciseDownloaded(
                        id: exercise.id,
                        name: exercise.name,
                        videoURL: fileURL,
                        description: exercise.description,
                        bodyArea: exercise.bodyArea,
                        level: exercise.level
                    )
                    completion(.success(downloadedExercise))
                } catch {
                    print("File move error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }

            task.resume()

        } catch {
            print(error.localizedDescription)
            completion(.failure(FileError.failed))
        }
    }

    
    static func saveVideoLocally(at path: String, video: Data) -> URL? {
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
}
