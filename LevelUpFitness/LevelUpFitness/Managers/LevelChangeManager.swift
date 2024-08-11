//
//  LevelChangeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/10/24.
//
import Foundation
import Amplify

class LevelChangeManager: ObservableObject {
    @Published var levelChanges: [LevelChangeInfo] = []
    
    var xpManager: XPManager
    
    init(xpManager: XPManager) {
        self.xpManager = xpManager
    }
    
    let allProperties = ["Weight", "Rest", "Endurance", "Consistency",]
    var currentProperties: [String] = []
    
    func addNewProgramLevelChanges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if let programName = await ProgramDynamoDBUtility.getUserProgramDBRepresentation() {
                if !LocalStorageUtility.fileModifiedInLast24Hours(at: "\(userID)-LevelChangeInfo.json") {
                    let selectedPropterties = selectedPropterties()
                    LocalStorageUtility.clearFile(at: "\(userID)-LevelChangeInfo.json")
                    
                    if let programs = LocalStorageUtility.getCachedUserPrograms(at: "Programs/\(userID)/\(programName)") {
                        for selectedPropterty in selectedPropterties {
                            await performProgramLevelChange(selectedProperty: selectedPropterty, programs: programs)
                        }
                    }
                }
            }
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
            var loadedProperties: [String] = []
            
            for levelChangeString in levelChangeStrings {
                if let levelChangeData = levelChangeString.data(using: .utf8) {
                    let levelChange = try jsonDecoder.decode(LevelChangeInfo.self, from: levelChangeData)
                    levelChanges.append(levelChange)
                    loadedProperties.append(levelChange.keyword)
                }
                else {
                    continue
                }
            }
            
            self.levelChanges = levelChanges
            self.currentProperties = loadedProperties
        } catch {
            print(error)
        }
        
    }
    
    func performProgramLevelChange(selectedProperty: String, programs: [Program]) async {
        switch selectedProperty {
            case "Weight":
                await addProgramWeightTrendContribution(programs: programs)
            default:
                break
        }
    }
    
    func addProgramWeightTrendContribution(programs: [Program]) async {
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
            
            let contribution = programs.getRestDifferentialTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Rest", description: "This is a measure of how your rest differential has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
        } catch {
            print(error)
        }
    }
    
    func addProgramConsistencyTrendContribution(programs: [Program]) async {
        do {
            guard let userID = try? await Amplify.Auth.getCurrentUser().userId else { return }
            
            let contribution = programs.getConsistencyTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Consistency", description: "This is a measure of how your consistency has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
        } catch {
            print(error)
        }
    }
    
    func addProgramRestTimeTrendContribution(programs: [Program]) async {
        do {
            guard let userID = try? await Amplify.Auth.getCurrentUser().userId else { return }
            
            let contribution = programs.getRestTimeTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Endurance", description: "This is a measure of how your endurance has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
        } catch {
            print(error)
        }
    }
    
    func selectedPropterties() -> [String] {
        let availableProperties = allProperties.filter({!currentProperties.contains($0)})
        return Array(availableProperties.shuffled().prefix(4))
    }
    
}
