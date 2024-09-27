//
//  ProgramManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

import Amplify
import CloudKit

import CloudKit
import Foundation
import SwiftUI

@MainActor
class ProgramManager: ObservableObject {
    static let shared = ProgramManager()

    @Published var standardProgramDBRepresentations: [StandardProgramDBRepresentation] = []
    @Published var userActivePrograms: [UserProgramDBRepresentation] = []
    @Published var userProgramData: [ProgramWithID] = [] 
    @Published var selectedProgram: ProgramWithID?

    @Published var exercises: [ExerciseLibraryExercise] = []
    
    @Published var retrievingProgram: Bool = false
    
    func leaveProgram(programID: String, completion: @escaping (Bool) -> Void) async {
            await ProgramCloudKitUtility.leaveProgram(programID: programID) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.userActivePrograms.removeAll { $0.programID == programID }
                        self.userProgramData.removeAll { $0.programID == programID }
                        completion(true)
                    }
                } else {
                    print("Failed to leave program: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }
    
    func loadStandardProgramNames() {
        ProgramCloudKitUtility.fetchStandardProgramDBRepresentations { programs, error in
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
        do {
            let userID = try await CKContainer.default().userRecordID().recordName
            
            await ProgramCloudKitUtility.fetchUserActivePrograms(userID: userID) { programs, error in
                if let programs = programs {
                    DispatchQueue.main.async {
                        self.userActivePrograms = programs
                    }
                } else if let error = error {
                    print("Error fetching active programs: \(error.localizedDescription)")
                }
            }
        } catch {
            print(error)
        }
    }

    func loadUserProgramData() async {
        for programMeta in userActivePrograms {
            await ProgramCloudKitUtility.fetchUserProgramData(programID: programMeta.programID) { programWithID, error in
                if let programWithID = programWithID {
                    DispatchQueue.main.async {
                        self.userProgramData.append(programWithID)
                    }
                } else if let error = error {
                    print("Error fetching user program data: \(error.localizedDescription)")
                }
            }
        }
    }

    func uploadNewProgramStatus(completion: @escaping (Bool) -> Void) async {
        guard let selectedProgram = self.selectedProgram else {
            print("No selected program to update")
            completion(false)
            return
        }
        
        let programID = selectedProgram.programID
        
        await ProgramCloudKitUtility.uploadNewProgramStatus(programID: programID, updatedProgram: selectedProgram.program) { success, error in
            if success {
                DispatchQueue.main.async {
                    print("Program status updated successfully.")
                    completion(true)
                }
            } else {
                DispatchQueue.main.async {
                    print("Failed to update program status: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }
        }
    }
}

