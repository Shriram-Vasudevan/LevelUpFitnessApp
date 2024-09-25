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
    @Published var standardProgramDBRepresentations: [StandardProgramDBRepresentation] = []
    @Published var userProgramNames: [String]?
    
    @Published var exercises: [ExerciseLibraryExercise] = []

    @Published var selectedProgram: Program?
    
    func joinStandardProgram(programName: String) async {
        ProgramCloudKitUtility.fetchStandardProgramData(programName: programName) { result, error in
            if let program = result {
                // Modify start date and weekday
                var modifiedProgram = program
                modifiedProgram.startDate = DateUtility.getCurrentDate()
                modifiedProgram.startWeekday = DateUtility.getCurrentWeekday()
                
                DispatchQueue.main.async {
                    self.program.append(modifiedProgram)
                    print("the program is \(self.program)")
                }
            } else if let error = error {
                print("Error joining standard program: \(error.localizedDescription)")
            }
        }
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
        guard let specificProgram = self.program.first(where: { $0.programName == programName }) else {
            print("couldn't get program to update")
            return
        }
        
        ProgramCloudKitUtility.saveProgram(program: specificProgram) { success, error in
            if success {
                completion(true)
            } else {
                completion(false)
                print("Error updating program: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    
    func leaveProgram(programName: String) async {
        ProgramCloudKitUtility.deleteProgram(programName: programName) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.program.removeAll(where: { $0.programName == programName })
                }
            } else {
                print("Error leaving program: \(String(describing: error?.localizedDescription))")
            }
        }
    }

    
    func getUserProgram() async {
        ProgramCloudKitUtility.fetchUserPrograms { programs, error in
            if let programs = programs {
                DispatchQueue.main.async {
                    self.program = programs
                    self.retrievingProgram = false
                }
            } else {
                print("Error fetching user programs: \(String(describing: error?.localizedDescription))")
                DispatchQueue.main.async {
                    self.retrievingProgram = false
                }
            }
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
