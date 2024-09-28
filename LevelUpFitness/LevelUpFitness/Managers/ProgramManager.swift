//
//  ProgramManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//
import Foundation
import CloudKit
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

    // MARK: - Leave Program
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

    // MARK: - Load Standard Program Names
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
        print("trying to join standard program")
        do {
            print("trying to join standard program 1")
            let userID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let startDate = DateUtility.getCurrentDate()
            
            print("trying to join standard program 2")
            
            ProgramCloudKitUtility.fetchStandardProgramData(programName: programName) { program, error in
                if let program = program {
                    ProgramCloudKitUtility.saveUserProgram(userID: userID, program: program, startDate: startDate) { programID, success, error in
                        if success {
                            DispatchQueue.main.async {
                                let newProgramWithID = ProgramWithID(programID: programID, program: program)
                                self.selectedProgram = newProgramWithID
                            }
                            print("Successfully saved program to user's private database")
                        } else {
                            print("Error saving program: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                } else if let error = error {
                    print("Error fetching standard program: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user record: \(error.localizedDescription)")
        }
    }


    func loadUserActivePrograms() async -> [UserProgramDBRepresentation] {
        var userActivePrograms: [UserProgramDBRepresentation] = []
        do {
            // Get the current user's ID
            let userID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            
            // Fetch the active programs and await the result
            userActivePrograms = try await ProgramCloudKitUtility.fetchUserActivePrograms(userID: userID)
            
            print("Successfully fetched active programs")
        } catch {
            print("Error fetching user record ID or programs: \(error.localizedDescription)")
        }
        
        // Return the fetched or empty array
        return userActivePrograms
    }


    // MARK: - Load User Program Data
    func loadUserProgramData() async {
        let activePrograms = await loadUserActivePrograms()
        print("the active program \(activePrograms)")
        for programMeta in activePrograms {
            print("looping through")
            ProgramCloudKitUtility.fetchUserProgramData(programID: programMeta.programID) { programWithID, error in
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

    // MARK: - Upload New Program Status
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
