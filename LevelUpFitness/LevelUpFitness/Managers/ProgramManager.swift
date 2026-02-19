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

    enum ProgramJoinError: Error, LocalizedError {
        case premiumRequired(programName: String)
        case networkError
        case userNotAuthenticated
        case programNotFound

        var errorDescription: String? {
            switch self {
            case .premiumRequired(let name):
                return "\(name) requires a Premium subscription"
            case .networkError:
                return "Unable to connect. Check your internet connection."
            case .userNotAuthenticated:
                return "Please sign in to join a program"
            case .programNotFound:
                return "This program is no longer available"
            }
        }
    }

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
        Task {
            await loadStandardProgramNamesAsync()
        }
    }

    func loadStandardProgramNamesAsync() async {
        await withCheckedContinuation { continuation in
        ProgramCloudKitUtility.fetchStandardProgramDBRepresentations { programs, error in
            if let programs = programs {
                DispatchQueue.main.async {
                    self.standardProgramDBRepresentations = programs
                }
            } else if let error = error {
                print("Error fetching standard programs: \(error.localizedDescription)")
            }
            continuation.resume()
        }
        }
    }

    func joinStandardProgram(
        programName: String,
        completionHandler: @escaping (ProgramWithID?) -> Void,
        errorHandler: @escaping (ProgramJoinError) -> Void
    ) async {
        print("trying to join standard program")
        let isPremiumProgram = standardProgramDBRepresentations.first(where: { $0.name == programName })?.isPremium ?? false
        if isPremiumProgram && !StoreKitManager.shared.effectiveIsPremiumUnlocked {
            print("Premium subscription required to join \(programName)")
            await MainActor.run {
                StoreKitManager.shared.recordPaywallTrigger(.premiumProgram(name: programName))
                errorHandler(.premiumRequired(programName: programName))
            }
            return
        }
        do {
            print("trying to join standard program 1")
            let userID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let startDate = DateUtility.getCurrentDate()

            print("trying to join standard program 2")

            ProgramCloudKitUtility.fetchStandardProgramData(programName: programName) { program, error in
                if let program = program {
                    var enrichedProgram = program
                    enrichedProgram.isPremium = program.isPremium || isPremiumProgram
                    ProgramCloudKitUtility.saveUserProgram(userID: userID, program: enrichedProgram, startDate: startDate) { programID, success, error in
                        if success {
                            let programWithID = ProgramWithID(programID: programID, program: enrichedProgram)

                            DispatchQueue.main.async {
                                self.userProgramData.append(programWithID)
                                print("Program with ID \(programID) set as selectedProgram and added to userProgramData")
                            }

                            completionHandler(programWithID)
                        } else {
                            print("Error saving program: \(error?.localizedDescription ?? "Unknown error")")
                            errorHandler(.networkError)
                            completionHandler(nil)
                        }
                    }
                } else if let error = error {
                    print("Error fetching standard program: \(error.localizedDescription)")
                    errorHandler(.programNotFound)
                    completionHandler(nil)
                }
            }
        } catch {
            print("Error getting user record: \(error.localizedDescription)")
            errorHandler(.userNotAuthenticated)
            completionHandler(nil)
        }
    }



    func loadUserActivePrograms() async -> [UserProgramDBRepresentation] {
        var userActivePrograms: [UserProgramDBRepresentation] = []
        do {
            let userID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            
            userActivePrograms = try await ProgramCloudKitUtility.fetchUserActivePrograms(userID: userID)
            
            print("Successfully fetched active programs")
        } catch {
            print("Error fetching user record ID or programs: \(error.localizedDescription)")
        }
        
        return userActivePrograms
    }


    // MARK: - Load User Program Data
    func loadUserProgramData() async {
        let activePrograms = await loadUserActivePrograms()
        print("the active program \(activePrograms)")
        var loadedPrograms: [ProgramWithID] = []

        for programMeta in activePrograms {
            do {
                if let programWithID = try await ProgramCloudKitUtility.fetchUserProgramData(programID: programMeta.programID) {
                    loadedPrograms.append(programWithID)
                }
            } catch {
                print("Error fetching user program data: \(error.localizedDescription)")
            }
        }

        userProgramData = loadedPrograms
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
