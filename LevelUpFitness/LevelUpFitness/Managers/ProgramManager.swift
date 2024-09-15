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
    
    @Published var program: [Program] = []
    @Published var retrievingProgram: Bool = false
    @Published var standardProgramDBRepresentations: [StandardProgramDBRepresentation]?
    @Published var userProgramNames: [String]?
    
    @Published var exercises: [ExerciseLibraryExercise] = []

    @Published var selectedProgram: Program?
    
    func joinStandardProgram(programName: String) async {
        await ProgramS3Utility.joinStandardProgram(programName: programName, completion: { result in
            switch result {
                case .success(let program):
                    DispatchQueue.main.sync {
                        self.program.append(program)
                        print("the program is \(self.program)")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        })
    }
    
    func getUserProgramNames() async {
        do {
            if let userProgramNames = await ProgramS3Utility.getUserProgramNames() {
                self.userProgramNames = try JSONDecoder().decode([String].self, from: userProgramNames)
                print("user program names: \(self.userProgramNames)")
            }
        } catch {
            print(error)
        }
    }
    
    func uploadNewProgramStatus(programName: String, completion: @escaping (Bool) -> Void) async {
        do {
            guard let specificProgram = self.program.first(where: { Program in
                Program.programName == programName
            }) else { return }
                    
            try await ProgramS3Utility.uploadNewProgramStatus(program: specificProgram, completionHandler: {
                completion(true)
            })
        } catch {
            completion(false)
        }
    }
    
    func leaveProgram(programName: String) async {
        await ProgramS3Utility.leaveProgram(programName: programName)
        await ProgramDynamoDBUtility.leaveProgram(programName: programName)
        
        self.program.removeAll(where: { Program in
            Program.programName == programName
        })
    }
    
    func getUserProgram() async {
        if let userProgramDBRepresentations = await ProgramDynamoDBUtility.getUserProgramDBRepresentation()  {
            for userProgramDBRepresentation in userProgramDBRepresentations {
                let endDate = DateUtility.getDateNWeeksAfterDate(dateString: userProgramDBRepresentation.startDate, weeks: 4)
                do {
                    DispatchQueue.main.async {
                        self.retrievingProgram = true
                    }
                    
                    let userID = try await Amplify.Auth.getCurrentUser().userId
                    
                    if !DateUtility.weekDurationExceeded(startDate: userProgramDBRepresentation.startDate, weeks: 4) {
                        guard let weekday = DateUtility.getWeekdayFromDate(date: userProgramDBRepresentation.startDate), let date = DateUtility.getLastDateForWeekday(weekday: weekday) else {
                            self.retrievingProgram = false
                            return
                        }
                        
                        if !LocalStorageUtility.userProgramSaved(userID: userID, programName: userProgramDBRepresentation.program, date: date, startDate: userProgramDBRepresentation.startDate) {
                            print("downloading: \("UserPrograms/\(userID)/\(userProgramDBRepresentation.program) (\(userProgramDBRepresentation.startDate)|\(endDate ?? ""))/\(date).json")")
                            let downloadTask = Amplify.Storage.downloadData(key: "UserPrograms/\(userID)/\(userProgramDBRepresentation.program) (\(userProgramDBRepresentation.startDate)|\(endDate ?? ""))/\(date).json")
                            
                            print("downloading")
                            
                            let data = try await downloadTask.value
                            
                            let decoder = JSONDecoder()
                            let decodedData = try decoder.decode(Program.self, from: data)
                            
                            DispatchQueue.main.async {
                                self.program.append(decodedData)
                            }

                            print("the program is this \(self.program)")
                            print("caching to local storage")
                            try LocalStorageUtility.cacheUserProgram(userID: userID, programName: userProgramDBRepresentation.program, date: date, program: decodedData)
                            
                            DispatchQueue.main.async {
                                self.retrievingProgram = false
                            }
                        } else {
                            if let fileURL = LocalStorageUtility.getUserProgramFileURL(userID: userID, programName: userProgramDBRepresentation.program, date: date, startDate: userProgramDBRepresentation.startDate) {
                                let data = try Data(contentsOf: fileURL)
                                let decoder = JSONDecoder()
                                let decodedData = try decoder.decode(Program.self, from: data)
                                
                                DispatchQueue.main.async {
                                    self.program.append(decodedData)
                                    self.retrievingProgram = false
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.retrievingProgram = false
                                }
                            }
                            
                            print("the program is this \(self.program)")
                            
                            print("Program loaded from local cache")
                        }
                    }
                    else {
                        await leaveProgram(programName: userProgramDBRepresentation.program)
                        GlobalCoverManager.shared.showProgramCompletion()
                    }
                } catch {
                    print("User program retrieval error: \(error)")
                    DispatchQueue.main.async {
                        self.retrievingProgram = false
                    }
                    
                    await ProgramS3Utility.joinStandardProgram(programName: userProgramDBRepresentation.program, completion: { result in
                        switch result {
                            case .success(let program):
                                self.program.append(program)
                            case .failure(let error):
                                print(error.localizedDescription)
                        }
                    })
                }
            }
            
        } else {
            print("cant get program db representation")
            self.standardProgramDBRepresentations = await ProgramS3Utility.getStandardProgramDBRepresentations()
        }
    }
    
    func getProgramsForInsights(programS3Representation: String) async -> [Program]? {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            var programs: [Program] = []
            
            if let paths = await S3Utility.getUserProgramFilePaths(programS3Representation: programS3Representation) {
                for path in paths {
                    if !LocalStorageUtility.userProgramSaved(userID: userID, programS3Representation: programS3Representation, fileName: path) {
                        let downloadTask = Amplify.Storage.downloadData(key: "UserPrograms/\(userID)/\(programS3Representation)/\(path)")
                        
                        let data = try await downloadTask.value
                        
                        let decoder = JSONDecoder()
                        let decodedData = try decoder.decode(Program.self, from: data)
                        
                        programs.append(decodedData)
                    } else {
                        if let url = LocalStorageUtility.getUserProgramFileURL(userID: userID, programS3Representation: programS3Representation, fileName: path) {
                            let programData = try Data(contentsOf: url)
                            let program = try JSONDecoder().decode(Program.self, from: programData)
                            programs.append(program)
                        }
                    }
                }
                print("the paths: \(paths)")
            }
            else {
                return nil
            }
            
            return programs
        } catch {
            print(error)
            return nil
        }
    }
}
