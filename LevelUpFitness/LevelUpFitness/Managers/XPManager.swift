//
//  XPManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import Foundation
import Amplify
import AWSAPIPlugin

@MainActor
class XPManager: ObservableObject {
    static let shared = XPManager()
    
    @Published var userXPData: XPData?
    @Published var levelChanges: [LevelChangeInfo] = []

    
    let allProperties = ["Weight", "Rest", "Endurance", "Consistency",]
    var currentProperties: [String] = []
    
    init() {
        Task {
            await getUserXPData()
            await getLevelChanges()
            await addNewProgramLevelChanges()
        }
    }
    
    func getUserXPData() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            var request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserXP", queryParameters: ["UserID" : userID])
            
            let response = try await Amplify.API.get(request: request)
            
            print("xp response: \(String(data: response, encoding: .utf8))")
            let decoder = JSONDecoder()
            let responseDecoded = try decoder.decode(XPDataResponse.self, from: response)
            
            DispatchQueue.main.async {
                self.userXPData = responseDecoded.item
            }
            
            
        } catch {
            print("xp error \(error)")
        }
    }
    
    func addXP(increment: Int, type: XPAdditionType) {
        print("add xp user xp \(userXPData)")
        guard var userXPData = userXPData else {
            print("User XP data is not available.")
            return
        }
        
        switch type {
            case .lowerBodyCompound:
                userXPData.subLevels.lowerBodyCompound.incrementXP(increment: increment)
            case .lowerBodyIsolation:
                userXPData.subLevels.lowerBodyIsolation.incrementXP(increment: increment)
            case .upperBodyCompound:
                userXPData.subLevels.upperBodyCompound.incrementXP(increment: increment)
            case .upperBodyIsolation:
                userXPData.subLevels.upperBodyIsolation.incrementXP(increment: increment)
            case .total:
                userXPData.xp += increment
                print("new xp \(userXPData.xp)")
                
            
                let newLevel = calculateLevel(fromXP: userXPData.xp)
                userXPData.level = newLevel
                        
                userXPData.xpNeeded = calculateXPForLevel(newLevel)
                
                Task {
                    await ChallengeManager.shared.checkForChallengeCompletion(challengeField: "Level", newValue: userXPData.level)
                }
        }
        
        self.userXPData = userXPData
        print("the new xp data \(self.userXPData)")
    }
    
    func addXPToDB() async {
        do {
            print("adding to db")
            guard let userXPData = userXPData else {
                print("User XP data is not available.")
                return
            }
            
            print(userXPData)
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let jsonData = try jsonEncoder.encode(userXPData)

            print(String(data: jsonData, encoding: .utf8))
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/updateUserXP", body: jsonData)
            let restResponse = try await Amplify.API.put(request: request)
            
            print("Update XP Response: \(String(data: restResponse, encoding: .utf8))")
        } catch {
            print("Update XP \(error)")
        }
    }
    
    func calculateLevel(fromXP xp: Int) -> Int {
        if xp < 50 {
            return 1
        }

        var level = 1
        var accumulatedXP = 50

        while xp >= accumulatedXP {
            level += 1
            accumulatedXP += level * 30
        }

        return level
    }

    func calculateXPForLevel(_ level: Int) -> Int {
        if level <= 1 {
            return 50
        }
        
        var totalXP = 50
        for currentLevel in 2...level {
            totalXP += currentLevel * 30
        }
        return totalXP
    }

    
    func addNewProgramLevelChanges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if let programName = await ProgramDynamoDBUtility.getUserProgramDBRepresentation() {
                print("program name \(programName)")
                if !LocalStorageUtility.fileModifiedInLast24Hours(at: "\(userID)-LevelChangeInfo.json") {
                    print("current properties \(currentProperties)")
                    let selectedPropterties = selectedProperties()
                    print("selected properties \(selectedPropterties)")
                    
                    if let programs = LocalStorageUtility.getCachedUserPrograms(at: "Programs/\(userID)/\(programName)") {
                        print("got programs")
                        let tasks = selectedPropterties.map { selectedProperty in
                                Task {
                                    await performProgramLevelChange(selectedProperty: selectedProperty, programs: programs)
                                }
                            }
      
                            for task in tasks {
                                _ = await task.value
                            }
                    }
                    
                    
                    await addXPToDB()
                    await getLevelChanges()
                    
                    print("level chagnes \(self.levelChanges)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getLevelChanges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            let filePath = "\(userID)-LevelChangeInfo.json"
            guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let fileURL = documentsDirectoryURL.appendingPathComponent(filePath)
            
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                try "".write(to: fileURL, atomically: true, encoding: .utf8)
                self.levelChanges = []
                self.currentProperties = []
                return
            }
            
            guard let fileContent = LocalStorageUtility.readDocumentsDirectoryJSONStringFile(at: filePath) else { return }

            let levelChangeStrings = fileContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
            var levelChanges: [LevelChangeInfo] = []
            
            let jsonDecoder = JSONDecoder()
            var loadedProperties: [String] = []
            
            for levelChangeString in levelChangeStrings {
                if let levelChangeData = levelChangeString.data(using: .utf8) {
                    do {
                        let levelChange = try jsonDecoder.decode(LevelChangeInfo.self, from: levelChangeData)
                        levelChanges.append(levelChange)
                        loadedProperties.append(levelChange.keyword)
                    } catch {
                        print("Failed to decode line: \(levelChangeString), error: \(error)")
                        continue
                    }
                }
            }
        
            if levelChanges.count > 4 {
                self.levelChanges = Array(levelChanges.suffix(4))
                self.currentProperties = Array(loadedProperties.suffix(4))
            } else {
                self.levelChanges = levelChanges
                self.currentProperties = loadedProperties
            }

            print("The last 4 level changes: \(self.levelChanges)")
        } catch {
            print("getLevelChanges \(error)")
        }
    }


    
    func performProgramLevelChange(selectedProperty: String, programs: [Program]) async {
        print("performProgramLevelChange")
        switch selectedProperty {
            case "Weight":
                print("Weight")
                await addProgramWeightTrendContribution(programs: programs)
            case "Rest":
            print("Rest")
                await addProgramRestDifferentialTrendContribution(programs: programs)
            case "Endurance":
            print("Endurance")
                await addProgramRestTimeTrendContribution(programs: programs)
            case "Consistency":
            print("Consistency")
                await addProgramConsistencyTrendContribution(programs: programs)
            default:
                break
        }
    }
    
    func addProgramWeightTrendContribution(programs: [Program]) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let contribution = programs.getWeightTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Weight", description: "This is a measure of how much weight you've been lifting over the past few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            appendLevelChangeToFile(levelChangeInfo: levelChangeInfo, contribution: contribution, userID: userID)
        } catch {
            print(error)
        }
    }
    
    func addProgramRestDifferentialTrendContribution(programs: [Program]) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let contribution = programs.getRestDifferentialTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Rest", description: "This is a measure of how your rest differential has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            appendLevelChangeToFile(levelChangeInfo: levelChangeInfo, contribution: contribution, userID: userID)
        } catch {
            print(error)
        }
    }
    
    func addProgramConsistencyTrendContribution(programs: [Program]) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let contribution = programs.getConsistencyTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Consistency", description: "This is a measure of how your consistency has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            appendLevelChangeToFile(levelChangeInfo: levelChangeInfo, contribution: contribution, userID: userID)
        } catch {
            print(error)
        }
    }
    
    func addProgramRestTimeTrendContribution(programs: [Program]) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let contribution = programs.getRestTimeTrendContribution()
            
            let levelChangeInfo = LevelChangeInfo(keyword: "Endurance", description: "This is a measure of how your endurance has been changing over the last few weeks", change: contribution, timestamp: Date().ISO8601Format())
            
            appendLevelChangeToFile(levelChangeInfo: levelChangeInfo, contribution: contribution, userID: userID)
        } catch {
            print(error)
        }
    }
    
    func appendLevelChangeToFile(levelChangeInfo: LevelChangeInfo, contribution: Int, userID: String) {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            print("appending level change for \(levelChangeInfo.keyword)")
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
//            levelChanges.append(levelChangeInfo)
            
            print("adding xp")
            XPManager.shared.addXP(increment: contribution, type: .total)
        } catch {
            print(error)
        }
    }
    
    func selectedProperties() -> [String] {
        let availableProperties = allProperties.filter { !currentProperties.contains($0) }
        
        var selectedProperties = Array(availableProperties.shuffled().prefix(4))

        if selectedProperties.count < 4 {
            let additionalProperties = Array(currentProperties.shuffled().prefix(4 - selectedProperties.count))
            selectedProperties.append(contentsOf: additionalProperties)
        }
        
        return selectedProperties
    }
    
}
