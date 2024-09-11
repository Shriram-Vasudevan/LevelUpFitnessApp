//
//  LocalStorageUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation
import UIKit

class LocalStorageUtility {
    private static let imageCache = NSCache<AnyObject, AnyObject>()
    
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
                
                let programsSorted = programs.sorted { $0.1 < $1.1 }
                print("programs sorter \(programsSorted)")
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
                
                //print("the program objects \(programObjects)")
                return programObjects
            } else {
                return nil
            }
        } catch {
            print("Error in getCachedUserPrograms: \(error)")
            return nil
        }
    }

    static func fileModifiedToday(at path: String) -> Bool {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        
        let fileURL = documentsDirectoryURL.appendingPathComponent(path)
        
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            
            if let modificationDate = fileAttributes[FileAttributeKey.modificationDate] as? Date {
                let calendar = Calendar.current
                if calendar.isDateInToday(modificationDate) {
                    return true
                }
                return false
            }
        } catch {
            print("file modification error \(error)")
            return false
        }
        
        return false
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
                
                print("time since mod \(timeSinceModification)")
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
        
        print("appending")
        
        guard let newlineData = "\n".data(using: .utf8) else {
            print("Failed to encode the newline character as UTF-8 data.")
            return
        }
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                    defer {
                        try? fileHandle.close()
                    }
                    try fileHandle.seekToEnd()
                    fileHandle.write(data)
                    fileHandle.write(newlineData)
                    
                    print("writing")
                }
            } else {
                print("does not exist")
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
                print("file does not exist")
            }
            
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

    static func updateTaskCompletionInFile(taskID: String, completed: Bool) {
        let fileManager = FileManager.default
        guard let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsDirectoryURL.appendingPathComponent("todoList.json")
        let tempFileURL = documentsDirectoryURL.appendingPathComponent("todoList_temp.json")
        
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            defer { try? fileHandle.close() }

            if fileManager.fileExists(atPath: tempFileURL.path) {
                try fileManager.removeItem(at: tempFileURL)
            }
            fileManager.createFile(atPath: tempFileURL.path, contents: nil, attributes: nil)
            guard let tempFileHandle = try? FileHandle(forWritingTo: tempFileURL) else { return }
            defer { try? tempFileHandle.close() }
            
            let jsonDecoder = JSONDecoder()
            let jsonEncoder = JSONEncoder()
            
            while let line = fileHandle.readLine() {
                if let data = line.data(using: .utf8),
                   var task = try? jsonDecoder.decode(ToDoListTask.self, from: data),
                   task.id == taskID {
                    task.completed = completed
                    if let updatedData = try? jsonEncoder.encode(task) {
                        tempFileHandle.write(updatedData)
                        tempFileHandle.write("\n".data(using: .utf8)!)
                    }
                } else {
                    tempFileHandle.write(line.data(using: .utf8)!)
                    tempFileHandle.write("\n".data(using: .utf8)!)
                }
            }
            
            try fileManager.removeItem(at: fileURL)
            try fileManager.moveItem(at: tempFileURL, to: fileURL)
            
        } catch {
            print("Error updating task completion status: \(error)")
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
    
    static func getUserProgramFileURL(userID: String, programS3Representation: String, fileName: String) -> URL? {
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectoryURL.appendingPathComponent("Programs/\(userID)/\(programS3Representation)/\(fileName)")
    }
    
    static func getUserProgramFileURL(userID: String, programName: String, date: String, startDate: String) -> URL? {
        let endDate = DateUtility.getDateNWeeksAfterDate(dateString: startDate, weeks: 4)
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentsDirectoryURL.appendingPathComponent("Programs/\(userID)/\(programName) (\(startDate)|\(endDate ?? "NoDate"))/\(date).json")
    }

    static func userProgramSaved(userID: String, programName: String, date: String, startDate: String) -> Bool {
        print("checking save")
        guard let fileURL = getUserProgramFileURL(userID: userID, programName: programName, date: date, startDate: startDate) else { return false }
        
        print("save \(FileManager.default.fileExists(atPath: fileURL.path))")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    static func userProgramSaved(userID: String, programS3Representation: String, fileName: String) -> Bool {
        print("checking save")
        guard let fileURL = getUserProgramFileURL(userID: userID, programS3Representation: programS3Representation, fileName: fileName) else { return false }
        
        print("save \(FileManager.default.fileExists(atPath: fileURL.path))")
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    static func cacheUserProgram(userID: String, programName: String, date: String, program: Program) throws {
        print("caching")
        let endDate = DateUtility.getDateNWeeksAfterDate(dateString: program.startDate, weeks: 4)
        
        print("Attempting to cache")
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let programsDirectoryURL = documentsDirectoryURL.appendingPathComponent("Programs")
        let userProgramsDirectoryURL = programsDirectoryURL.appendingPathComponent(userID)
        let specificUserProgramDirectory = userProgramsDirectoryURL.appendingPathComponent("\(programName) (\(program.startDate)|\(endDate ?? "NoDate"))")
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
    
    static func profilePictureSaved(userID: String) -> (Data?) {
        guard let image = imageCache.object(forKey: userID as AnyObject) as? UIImage else { return nil }
        return image.pngData()
    }
    
    static func saveProfilePicture(pfpData: Data, userID: String) {
        if let image = UIImage(data: pfpData) {
            imageCache.setObject(image, forKey: userID as AnyObject)
        }
    }
    
    static func removeImageCache(userID: String) {
        imageCache.removeObject(forKey: userID as AnyObject)
    }

    
    static func downloadVideoAndSaveToTempFile(url: URL, completion: @escaping (Result<URL, Error>) -> Void)
    {
        do {
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileURL = tempDirectory.appendingPathComponent("\(UUID()).mp4")

            let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
                guard let location = location, error == nil else {
                    print("Failed to download video: \(error?.localizedDescription ?? "Unknown error")")
                    completion(.failure(error ?? FileError.failed))
                    return
                }
                
                print("The response: \(String(describing: response))")
                
                do {
                    try FileManager.default.moveItem(at: location, to: fileURL)
                    completion(.success(fileURL))
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
