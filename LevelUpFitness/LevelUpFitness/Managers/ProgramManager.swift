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
        case alreadyJoined(programName: String)

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
            case .alreadyJoined(let name):
                return "You are already enrolled in \(name)"
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
                    StoreKitManager.shared.registerProgramSubscriptionRequirements(programs)
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
        let normalizedIncoming = normalizeProgramName(programName)
        let alreadyJoined = userProgramData.contains {
            normalizeProgramName($0.program.programName) == normalizedIncoming
        } || userActivePrograms.contains {
            normalizeProgramName($0.program) == normalizedIncoming
        }

        if alreadyJoined {
            await MainActor.run {
                errorHandler(.alreadyJoined(programName: programName))
                completionHandler(nil)
            }
            return
        }

        print("trying to join standard program")
        let programMetadata = standardProgramDBRepresentations.first {
            normalizeProgramName($0.name) == normalizedIncoming
        }
        let requiresSubscription = programMetadata?.requiresSubscription ?? false
        let canAccessProgram = programMetadata.map { StoreKitManager.shared.canAccessProgram($0) } ?? true

        if requiresSubscription && !canAccessProgram {
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
                    enrichedProgram.isPremium = program.isPremium || (programMetadata?.isPremium ?? false)
                    ProgramCloudKitUtility.saveUserProgram(userID: userID, program: enrichedProgram, startDate: startDate) { programID, success, error in
                        if success {
                            let programWithID = ProgramWithID(programID: programID, program: enrichedProgram)
                            let metadata = UserProgramDBRepresentation(
                                userID: userID,
                                program: enrichedProgram.programName,
                                startDate: startDate,
                                programID: programID
                            )

                            DispatchQueue.main.async {
                                self.userProgramData.append(programWithID)
                                self.userActivePrograms.append(metadata)
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

    private func normalizeProgramName(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: .diacriticInsensitive, locale: .current)
            .lowercased()
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

        userActivePrograms = activePrograms
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

enum FriendWorkoutContext: String, CaseIterable {
    case program = "Program"
    case gym = "Gym"

    var title: String {
        switch self {
        case .program:
            return "Program"
        case .gym:
            return "Gym"
        }
    }
}

struct FriendWorkoutRoom: Identifiable, Hashable {
    let id: String
    let title: String
    let scheduleDate: Date
    let context: FriendWorkoutContext
    let participantCount: Int
    let joined: Bool
    let hostedByCurrentUser: Bool
    let roomCode: String
    let isPublic: Bool

    var scheduleLabel: String {
        scheduleDate.formatted(.dateTime.weekday(.abbreviated).hour().minute())
    }

    var contextLabel: String {
        context.title
    }
}

@MainActor
class FriendWorkoutManager: ObservableObject {
    static let shared = FriendWorkoutManager()

    @Published private(set) var programRooms: [FriendWorkoutRoom] = []
    @Published private(set) var gymRooms: [FriendWorkoutRoom] = []
    @Published private(set) var globalRooms: [FriendWorkoutRoom] = []
    @Published var syncErrorMessage: String?
    @Published var syncing = false

    private let recordType = "FriendWorkoutRoom"
    private let database = ProgramCloudKitUtility.customContainer.publicCloudDatabase

    func rooms(for context: FriendWorkoutContext) -> [FriendWorkoutRoom] {
        switch context {
        case .program:
            return programRooms
        case .gym:
            return gymRooms
        }
    }

    func refreshIfNeeded(context: FriendWorkoutContext) async {
        if rooms(for: context).isEmpty {
            await refresh(context: context)
        }

        if globalRooms.isEmpty {
            await refreshGlobalDirectory()
        }
    }

    func refresh(context: FriendWorkoutContext) async {
        syncing = true
        defer { syncing = false }

        do {
            let currentUserID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let rooms = try await fetchRooms(context: context, currentUserID: currentUserID)

            switch context {
            case .program:
                programRooms = rooms
            case .gym:
                gymRooms = rooms
            }
            syncErrorMessage = nil
        } catch {
            syncErrorMessage = "Unable to sync friend workouts right now. Please try again."
            print("Friend workout refresh error: \(error.localizedDescription)")
        }
    }

    func refreshGlobalDirectory() async {
        syncing = true
        defer { syncing = false }

        do {
            let currentUserID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            globalRooms = try await fetchGlobalRooms(currentUserID: currentUserID)
            syncErrorMessage = nil
        } catch {
            syncErrorMessage = "Unable to load global rooms right now."
            print("Friend workout global refresh error: \(error.localizedDescription)")
        }
    }

    @discardableResult
    func createRoom(
        context: FriendWorkoutContext,
        title: String,
        scheduleDate: Date,
        isPublic: Bool = true
    ) async -> Bool {
        syncing = true
        defer { syncing = false }

        do {
            let currentUserID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let roomID = UUID().uuidString
            let record = CKRecord(recordType: recordType, recordID: CKRecord.ID(recordName: roomID))

            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            record["ID"] = roomID as CKRecordValue
            record["Title"] = (trimmedTitle.isEmpty ? defaultRoomTitle(for: context) : trimmedTitle) as CKRecordValue
            record["Environment"] = context.rawValue as CKRecordValue
            record["ScheduleDate"] = scheduleDate as CKRecordValue
            record["HostUserID"] = currentUserID as CKRecordValue
            record["ParticipantIDs"] = [currentUserID] as CKRecordValue
            record["CreatedAt"] = Date() as CKRecordValue
            record["IsActive"] = true as CKRecordValue
            record["RoomCode"] = generateRoomCode() as CKRecordValue
            record["IsPublicRoom"] = isPublic as CKRecordValue

            _ = try await save(record: record)
            await refresh(context: context)
            await refreshGlobalDirectory()
            return true
        } catch {
            syncErrorMessage = "Could not create room. Check network and CloudKit permissions."
            print("Friend workout room creation error: \(error.localizedDescription)")
            return false
        }
    }

    @discardableResult
    func joinRoom(withCode roomCode: String) async -> Bool {
        syncing = true
        defer { syncing = false }

        do {
            let normalizedCode = normalizeRoomCode(roomCode)
            guard !normalizedCode.isEmpty else {
                syncErrorMessage = "Enter a valid room code."
                return false
            }

            let currentUserID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let query = CKQuery(recordType: recordType, predicate: NSPredicate(format: "RoomCode == %@", normalizedCode))
            let records = try await perform(query: query)

            guard let record = records.first else {
                syncErrorMessage = "Room code not found."
                return false
            }

            let isActive = (record["IsActive"] as? Bool) ?? true
            guard isActive else {
                syncErrorMessage = "This room is no longer active."
                return false
            }

            let isPublicRoom = (record["IsPublicRoom"] as? Bool) ?? true
            guard isPublicRoom else {
                syncErrorMessage = "This room is private."
                return false
            }

            let hostUserID = record["HostUserID"] as? String ?? ""
            var participantIDs = record["ParticipantIDs"] as? [String] ?? []
            if !hostUserID.isEmpty && !participantIDs.contains(hostUserID) {
                participantIDs.append(hostUserID)
            }

            if !participantIDs.contains(currentUserID) {
                participantIDs.append(currentUserID)
                record["ParticipantIDs"] = Array(Set(participantIDs)) as CKRecordValue
                _ = try await save(record: record)
            }

            if let contextString = record["Environment"] as? String,
               let context = FriendWorkoutContext(rawValue: contextString) {
                await refresh(context: context)
            } else {
                await refresh(context: .program)
                await refresh(context: .gym)
            }
            await refreshGlobalDirectory()
            return true
        } catch {
            syncErrorMessage = "Could not join room by code."
            print("Friend workout join by code error: \(error.localizedDescription)")
            return false
        }
    }

    @discardableResult
    func toggleMembership(room: FriendWorkoutRoom) async -> Bool {
        syncing = true
        defer { syncing = false }

        do {
            let currentUserID = try await ProgramCloudKitUtility.customContainer.userRecordID().recordName
            let record = try await fetchRecord(withID: room.id)
            let hostUserID = record["HostUserID"] as? String ?? ""

            var participantIDs = record["ParticipantIDs"] as? [String] ?? []
            if !hostUserID.isEmpty && !participantIDs.contains(hostUserID) {
                participantIDs.append(hostUserID)
            }

            if participantIDs.contains(currentUserID) {
                if currentUserID != hostUserID {
                    participantIDs.removeAll { $0 == currentUserID }
                }
            } else {
                participantIDs.append(currentUserID)
            }

            record["ParticipantIDs"] = Array(Set(participantIDs)) as CKRecordValue
            _ = try await save(record: record)
            await refresh(context: room.context)
            await refreshGlobalDirectory()
            return true
        } catch {
            syncErrorMessage = "Could not update participation. Please retry."
            print("Friend workout membership error: \(error.localizedDescription)")
            return false
        }
    }

    private func defaultRoomTitle(for context: FriendWorkoutContext) -> String {
        switch context {
        case .program:
            return "Program Session"
        case .gym:
            return "Gym Session"
        }
    }

    private func fetchRooms(context: FriendWorkoutContext, currentUserID: String) async throws -> [FriendWorkoutRoom] {
        let predicate = NSPredicate(format: "Environment == %@", context.rawValue)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "ScheduleDate", ascending: true)]

        let records = try await perform(query: query)
        return records.compactMap { room(from: $0, currentUserID: currentUserID, fallbackContext: context) }
    }

    private func fetchGlobalRooms(currentUserID: String) async throws -> [FriendWorkoutRoom] {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "ScheduleDate", ascending: true)]

        let records = try await perform(query: query)
        return records.compactMap { room(from: $0, currentUserID: currentUserID, fallbackContext: nil) }
    }

    private func room(
        from record: CKRecord,
        currentUserID: String,
        fallbackContext: FriendWorkoutContext?
    ) -> FriendWorkoutRoom? {
        let context: FriendWorkoutContext
        if let environment = record["Environment"] as? String,
           let parsed = FriendWorkoutContext(rawValue: environment) {
            context = parsed
        } else if let fallbackContext {
            context = fallbackContext
        } else {
            return nil
        }

        let roomID = (record["ID"] as? String) ?? record.recordID.recordName
        let title = (record["Title"] as? String) ?? defaultRoomTitle(for: context)
        let scheduleDate = (record["ScheduleDate"] as? Date) ?? Date()
        let hostUserID = (record["HostUserID"] as? String) ?? ""
        let active = (record["IsActive"] as? Bool) ?? true
        guard active else { return nil }

        let isPublicRoom = (record["IsPublicRoom"] as? Bool) ?? true
        let participantIDs = record["ParticipantIDs"] as? [String] ?? []
        let normalizedParticipantIDs = Array(
            Set(participantIDs + (hostUserID.isEmpty ? [] : [hostUserID]))
        )
        let joined = normalizedParticipantIDs.contains(currentUserID)

        if !isPublicRoom && !joined && hostUserID != currentUserID {
            return nil
        }

        let roomCode = normalizeRoomCode(
            (record["RoomCode"] as? String) ?? String(roomID.prefix(6))
        )

        return FriendWorkoutRoom(
            id: roomID,
            title: title,
            scheduleDate: scheduleDate,
            context: context,
            participantCount: max(normalizedParticipantIDs.count, 1),
            joined: joined,
            hostedByCurrentUser: hostUserID == currentUserID,
            roomCode: roomCode,
            isPublic: isPublicRoom
        )
    }

    private func perform(query: CKQuery) async throws -> [CKRecord] {
        try await withCheckedThrowingContinuation { continuation in
            database.perform(query, inZoneWith: nil) { records, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: records ?? [])
            }
        }
    }

    private func fetchRecord(withID recordID: String) async throws -> CKRecord {
        try await withCheckedThrowingContinuation { continuation in
            database.fetch(withRecordID: CKRecord.ID(recordName: recordID)) { record, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let record else {
                    continuation.resume(throwing: NSError(domain: "FriendWorkoutRoom", code: 404))
                    return
                }
                continuation.resume(returning: record)
            }
        }
    }

    private func save(record: CKRecord) async throws -> CKRecord {
        try await withCheckedThrowingContinuation { continuation in
            database.save(record) { savedRecord, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let savedRecord else {
                    continuation.resume(throwing: NSError(domain: "FriendWorkoutRoom", code: 500))
                    return
                }
                continuation.resume(returning: savedRecord)
            }
        }
    }

    private func normalizeRoomCode(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics
        let normalizedScalars = value.uppercased().unicodeScalars.filter { allowed.contains($0) }
        return String(String.UnicodeScalarView(normalizedScalars))
    }

    private func generateRoomCode(length: Int = 6) -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<length).map { _ in alphabet.randomElement() ?? "X" })
    }
}
