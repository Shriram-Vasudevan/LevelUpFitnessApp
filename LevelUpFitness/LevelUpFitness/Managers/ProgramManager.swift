//
//  ProgramManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

import Amplify
import CloudKit

@MainActor
class ProgramManager: ObservableObject {
    static let shared = ProgramManager()
    
    @Published var standardProgramDBRepresentations: [StandardProgramDBRepresentation] = []
    @Published var userActivePrograms: [UserProgramDBRepresentation] = []
    @Published var programs: [Program] = []
    
    func loadStandardProgramNames() async {
        await ProgramCloudKitUtility.fetchStandardProgramDBRepresentations { programs, error in
            if let programs = programs {
                DispatchQueue.main.async {
                    self.standardProgramDBRepresentations = programs
                }
            } else if let error = error {
                print("Error fetching standard programs: \(error.localizedDescription)")
            }
        }
    }
    
    func joinStandardProgram(programName: String) async {
        let userID = try! await CKContainer.default().userRecordID().recordName
        let startDate = DateUtility.getCurrentDate()
        
        await ProgramCloudKitUtility.fetchStandardProgramData(programName: programName) { program, error in
            if let program = program {
                ProgramCloudKitUtility.saveUserProgram(userID: userID, program: program, startDate: startDate) { success, error in
                    if success {
                        print("Successfully saved program to user's private database")
                    } else {
                        print("Error saving program: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            } else if let error = error {
                print("Error fetching standard program: \(error.localizedDescription)")
            }
        }
    }

    func loadUserActivePrograms() async {
        let userID = try! await CKContainer.default().userRecordID().recordName
        
        await ProgramCloudKitUtility.fetchUserActivePrograms(userID: userID) { programs, error in
            if let programs = programs {
                DispatchQueue.main.async {
                    self.userActivePrograms = programs
                }
            } else if let error = error {
                print("Error fetching active programs: \(error.localizedDescription)")
            }
        }
    }

    func loadUserProgramData() async {
        for programMeta in userActivePrograms {
            await ProgramCloudKitUtility.fetchUserProgramData(programID: programMeta.programID) { program, error in
                if let program = program {
                    DispatchQueue.main.async {
                        self.programs.append(program)
                    }
                } else if let error = error {
                    print("Error fetching user program data: \(error.localizedDescription)")
                }
            }
        }
    }
}

