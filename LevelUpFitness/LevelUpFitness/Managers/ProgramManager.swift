//
//  ProgramManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

import Amplify

@MainActor
class ProgramManager: ObservableObject {
    static let shared = ProgramManager()
    
    @Published var program: Program?
    @Published var retrievingProgram: Bool = false
    @Published var standardProgramNames: [String]?
    @Published var userProgramNames: [String]?
    
    @Published var exercises: [ExerciseLibraryExercise] = []

    func joinStandardProgram(programName: String, badgeManager: BadgeManager) async {
        await ProgramS3Utility.joinStandardProgram(programName: programName, badgeManager: badgeManager, completion: { result in
            switch result {
                case .success(let program):
                    self.program = program
                case .failure(let error):
                    print(error.localizedDescription)
            }
        })
    }
    
    func getUserProgramNames() async {
        if let userProgramNames = await ProgramS3Utility.getUserProgramNames() {
            self.userProgramNames = userProgramNames
        }
    }
    
    func uploadNewProgramStatus(completion: @escaping (Bool) -> Void) async {
        do {
            guard let program = self.program else {
                completion(false)
                return
            }
            try await ProgramS3Utility.uploadNewProgramStatus(program: program, completionHandler: {
                completion(true)
            })
        } catch {
            completion(false)
        }
    }
    
    func leaveProgram() async {
        guard let programName = self.program?.programName else { return }
        await ProgramS3Utility.leaveProgram(programName: programName)
        await ProgramDynamoDBUtility.leaveProgram(programName: programName)
        
        self.program = nil
    }
    
    func getUserProgram(badgeManager: BadgeManager) async {
        if let programName = await ProgramDynamoDBUtility.getUserProgramDBRepresentation() {
            do {
                DispatchQueue.main.async {
                    self.retrievingProgram = true
                }
                
                let userID = try await Amplify.Auth.getCurrentUser().userId
                guard let date = DateUtility.getPreviousMondayDate() else {
                    self.retrievingProgram = false
                    return
                }
                
                if !LocalStorageUtility.userProgramSaved(userID: userID, programName: programName, date: date) {
                    let downloadTask = Amplify.Storage.downloadData(key: "UserPrograms/\(userID)/\(programName)/(\(date)).json")
                    
                    let data = try await downloadTask.value
                    
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(Program.self, from: data)
                    
                    DispatchQueue.main.async {
                        self.program = decodedData
                        print(self.program)
                    }

                    try LocalStorageUtility.cacheUserProgram(userID: userID, programName: programName, date: date, program: decodedData)
                    
                    DispatchQueue.main.async {
                        self.retrievingProgram = false
                    }
                } else {
                    if let fileURL = LocalStorageUtility.getUserProgramFileURL(userID: userID, programName: programName, date: date) {
                        let data = try Data(contentsOf: fileURL)
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(Program.self, from: data)
                        
                        DispatchQueue.main.async {
                            self.program = decodedData
                            self.retrievingProgram = false
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.retrievingProgram = false
                        }
                    }
                    print("Program loaded from local cache")
                }
            } catch {
                print("User program retrieval error: \(error)")
                DispatchQueue.main.async {
                    self.retrievingProgram = false
                }
                
                await ProgramS3Utility.joinStandardProgram(programName: programName, badgeManager: badgeManager, completion: { result in
                    switch result {
                        case .success(let program):
                            self.program = program
                        case .failure(let error):
                            print(error.localizedDescription)
                    }
                })
            }
        } else {
            self.standardProgramNames = await ProgramS3Utility.getStandardProgramNames()
        }
    }

}
