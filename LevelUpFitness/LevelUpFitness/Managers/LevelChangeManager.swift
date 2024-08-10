//
//  LevelChangeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/10/24.
//
import Foundation
import Amplify

class LevelManager: ObservableObject {
    @Published var levelChanges: [LevelChangeInfo] = []
    
    var programManager: ProgramManager
    var xpManager: XPManager
    
    init(programManager: ProgramManager, xpManager: XPManager) {
        self.programManager = programManager
        self.xpManager = xpManager
    }
    
    func performLevelChanges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if !LocalStorageUtility.fileModifiedInLast24Hours(at: "\(userID)-LevelChangeInfo.json") {
                
            }
        } catch {
            print(error)
        }
    }
    
    func addProgramWorkoutTrendContribution(programs: [Program]) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let contribution = programs.getWeightTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Weight", description: "This is a measure of how much weight you've been lifting over the past few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
        } catch {
            print(error)
        }
    }
    
    func addProgramRestDifferentialTrendContribution(programs: [Program]) async {
        do {
            guard let userID = try? await Amplify.Auth.getCurrentUser().userId else { return }
            
            let contribution = programs.getRestDifferentialContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Rest", description: "This is a measure of how your rest differential has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
        } catch {
            print(error)
        }
    }
    
    func getLevelChanges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            guard let fileContent = LocalStorageUtility.readDocumentsDirectoryJSONStringFile(at: "\(userID)-LevelChangeInfo.json") else { return }
            
            let levelChangeStrings = fileContent.components(separatedBy: .newlines)
            var levelChanges: [LevelChangeInfo] = []
            
            let jsonDecoder = JSONDecoder()
            
            for levelChangeString in levelChangeStrings {
                if let levelChangeData = levelChangeString.data(using: .utf8) {
                    let levelChange = try jsonDecoder.decode(LevelChangeInfo.self, from: levelChangeData)
                    levelChanges.append(levelChange)
                }
                else {
                    continue
                }
            }
            
            self.levelChanges = levelChanges
        } catch {
            print(error)
        }
        
    }
}
