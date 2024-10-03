//
//  LevelChangeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/10/24.
//
import Foundation
import Amplify
import Combine

@MainActor
class LevelChangeManager: ObservableObject {
    static let shared = LevelChangeManager()
    
    @Published var levelChanges: [LevelChangeInfo] = []
    
    let programProperties = ["Weight", "Rest", "Endurance", "Consistency"]
    var currentProperties: [String] = []
    

    func addNewProgramLevelChanges() async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            if let userProgramDBRepresentations = await ProgramDynamoDBUtility.getUserProgramDBRepresentation() {
                for userProgramDBRepresentation in userProgramDBRepresentations {
                    let endDate = DateUtility.getDateNWeeksAfterDate(dateString: userProgramDBRepresentation.startDate, weeks: 4)
                    
                    print("program name \(userProgramDBRepresentation.program)")
                    if !LocalStorageUtility.fileModifiedInLast24Hours(at: "\(userID)-LevelChangeInfo.json") {
                        print("current properties \(currentProperties)")
                        let selectedPropterties = selectedProperties()
                        print("selected properties \(selectedPropterties)")
                        
                        if let programs = LocalStorageUtility.getCachedUserPrograms(at: "Programs/\(userID)/\(userProgramDBRepresentation.program) (\(userProgramDBRepresentation.startDate)|\(String(describing: endDate)))") {
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
                        
                        await getLevelChanges()
                        
                        print("level chagnes \(self.levelChanges)")
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

    func createNewLevelChange(property: String, contribution: Int) async {
        switch property {
            case "ChallengeSuccess":
                await addLevelChange(contribution: contribution, keyword: "Challenge Success", description: "You completed your challenge!")
            case "Program":
                await addLevelChange(contribution: contribution, keyword: "Program", description: "Completed your program for today!")
            case "AddedWeight":
                await addLevelChange(contribution: contribution, keyword: "Added Weight", description: "For adding your Weight today!")
            case "MetStepsGoal":
                await addLevelChange(contribution: contribution, keyword: "Met Steps Goal", description: "You crushed your steps goal!")
            case "MetXPGoal":
                await addLevelChange(contribution: contribution, keyword: "Met XP Goal", description: "You're on top of your XP!")
            case "ChallengeFailed":
                await addLevelChange(contribution: contribution, keyword: "Challenge Failed", description: "You failed to complete your challenge.")
            case "GymSessionCompleted":
                await addLevelChange(contribution: contribution, keyword: "Gym Session Completed", description: "You tracked your gym session!")
            case "JoinedLevelUp":
                await addLevelChange(contribution: contribution, keyword: "Welcome to Level Up!", description: "We're happy to have you!")
            default:
                break
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
    
    func addLevelChange(contribution: Int, keyword: String, description: String) async {
        do {
            print("adding level change")
            let userID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let levelChangeInfo = LevelChangeInfo(keyword: keyword, description: description, change: contribution, timestamp: Date().ISO8601Format())
            
            print("level change info \(levelChangeInfo)")
            appendLevelChangeToFile(levelChangeInfo: levelChangeInfo, contribution: contribution, userID: userID)
        } catch {
            print("add level change error \(error)")
        }
    }
    
    func appendLevelChangeToFile(levelChangeInfo: LevelChangeInfo, contribution: Int, userID: String) {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(levelChangeInfo)
            
            print("appending level change for \(levelChangeInfo.keyword)")
            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "\(userID)-LevelChangeInfo.json", data: jsonData)
//            levelChanges.append(levelChangeInfo)
            
            addLevelChangeToArray(levelChangeInfo: levelChangeInfo)
            
            print("adding xp")
            XPManager.shared.addXP(increment: contribution, type: .total)
        } catch {
            print(error)
        }
    }
    
    func addLevelChangeToArray(levelChangeInfo: LevelChangeInfo) {
        print("apending to array")
        if self.levelChanges.count >= 4 {
            self.levelChanges.remove(at: 0)
            self.levelChanges.append(levelChangeInfo)
        }
        else {
            self.levelChanges.append(levelChangeInfo)
        }
    }
    
    func selectedProperties() -> [String] {
        let availableProperties = programProperties.filter { !currentProperties.contains($0) }
        
        var selectedProperties = Array(availableProperties.shuffled().prefix(4))

        if selectedProperties.count < 4 {
            let additionalProperties = Array(currentProperties.shuffled().prefix(4 - selectedProperties.count))
            selectedProperties.append(contentsOf: additionalProperties)
        }
        
        return selectedProperties
    }
    
}
