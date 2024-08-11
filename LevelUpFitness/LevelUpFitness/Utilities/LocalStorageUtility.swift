//
//  LocalStorageUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

class LocalStorageUtility {
    static func getCachedUserPrograms(at path: String) -> [Program]? {
        do {
            guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
            let directoryURL = documentsDirectoryURL.appendingPathComponent(path)
            
            if FileManager.default.fileExists(atPath: directoryURL.path) {
                var programs: [(String, Date)] = []
                let files = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
                
                for file in files {
                    let fileURL = directoryURL.appendingPathComponent(file)
                    let fileInfo = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                    if let modificationDate = fileInfo[FileAttributeKey.modificationDate] as? Date {
                        print("fileName: \(file)")
                        programs.append((file, modificationDate))
                    }
                }
                
                let programsSorted = programs.sorted { $0.1 > $1.1 }
                
                let jsonDecoder = JSONDecoder()
                var programObjects: [Program] = []
                
                for (fileName, _) in programsSorted.prefix(5) {
                    guard fileName.hasSuffix(".json") else {
                        print("Skipping non-JSON file: \(fileName)")
                        continue
                    }
                    
                    let fileURL = directoryURL.appendingPathComponent(fileName)
                    let jsonData = try Data(contentsOf: fileURL)
                    let decodedData = try jsonDecoder.decode(Program.self, from: jsonData)
                    programObjects.append(decodedData)
                }
                
                print("the program objects \(programObjects)")
                return programObjects
            } else {
                return nil
            }
        } catch {
            print("Error in getCachedUserPrograms: \(error)")
            return nil
        }
    }

    
    static func fileModifiedInLast24Hours(at path: String) -> Bool {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        do {
            let fileInfo = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            
            if let creationDate = fileInfo[FileAttributeKey.creationDate] as? Date {
                let currentDate = Date()
                let timeSinceCreation = currentDate.timeIntervalSince(creationDate)
                
                if timeSinceCreation <= 20 {
                    return false
                }
            }

            if let modificationDate = fileInfo[FileAttributeKey.modificationDate] as? Date {
                let currentDate = Date()
                let timeSinceModification = currentDate.timeIntervalSince(modificationDate)
                
                if timeSinceModification <= 86400 {
                    return true
                }
            }
        } catch {
            print("Error checking file attributes: \(error)")
            return false
        }
        
        return false
    }

    static func appendDataToDocumentsDirectoryFile(at path: String, data: Data) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        guard let newlineData = "\n".data(using: .utf8) else {
            print("Failed to encode the newline character as UTF-8 data.")
            return
        }
        
        do {
            let directoryURL = fileURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: directoryURL.path) {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                    defer {
                        try? fileHandle.close()
                    }
                    try fileHandle.seekToEnd()
                    fileHandle.write(data)
                    fileHandle.write(newlineData)
                }
            } else {
                try (data + newlineData).write(to: fileURL)
            }
        } catch {
            print("Error in appendDataToDocumentsDirectoryFile: \(error)")
        }
    }

    
    static func clearFile(at path: String) {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        do {
            let directoryURL = fileURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: directoryURL.path) {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Clear the file contents
            try "".write(to: fileURL, atomically: true, encoding: .utf8)
            print("File cleared successfully at path: \(path)")
        } catch {
            print("Error clearing file: \(error)")
        }
    }

    
    static func readDocumentsDirectoryJSONStringFile(at path: String) -> String? {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        do {
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("File does not exist at path: \(fileURL.path)")
                return nil
            }
            
            let fileContent = try String(contentsOf: fileURL, encoding: .utf8)
            return fileContent
        } catch {
            print("Error in readDocumentsDirectoryJSONStringFile: \(error)")
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
