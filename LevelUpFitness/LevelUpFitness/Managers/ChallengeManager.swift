//
//  ChallengeManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/10/24.
//

import Foundation
import CloudKit

@MainActor
class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()

    @Published var challengeTemplates: [ChallengeTemplate] = []
    @Published var userChallenges: [UserChallenge] = []

    // MARK: - ChallengeManager Initialization
    func challengeManagerInitialization() async {
        async let getChallengeTemplates: () = await fetchChallengeTemplates()
        async let getActiveUserChallenges: () = await fetchActiveUserChallenges()
        
        _ = await(getChallengeTemplates, getActiveUserChallenges)
    }

    // MARK: - Fetch Challenge Templates
    func fetchChallengeTemplates() async {
        await ChallengeCloudKitUtility.fetchChallengeTemplates { templates, error in
            if let templates = templates {
                DispatchQueue.main.async {
                    self.challengeTemplates = templates
                }
            } else if let error = error {
                print("Error fetching challenge templates: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Fetch Active User Challenges
    func fetchActiveUserChallenges() async {
        do {
            let userID = try await ChallengeCloudKitUtility.customContainer.userRecordID().recordName
            
            await ChallengeCloudKitUtility.fetchUserChallenges(userID: userID) { challenges, error in
                if let challenges = challenges {
                    DispatchQueue.main.async {
                        let isoFormatter = ISO8601DateFormatter()
                        
                        // Filter out expired challenges
                        self.userChallenges = challenges.filter {
                            isoFormatter.date(from: $0.endDate) ?? Date() > Date()
                        }
                        
                        // Handle failed challenges
                        let failedChallengesCount = challenges.count - self.userChallenges.count
                        if failedChallengesCount > 0 {
                            Task {
                                await LevelChangeManager.shared.createNewLevelChange(property: "ChallengeFailed", contribution: failedChallengesCount * -10)
                            }
                        }
                    }
                } else if let error = error {
                    print("Error fetching user challenges: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user record ID: \(error.localizedDescription)")
        }
    }

    // MARK: - Create a New Challenge
    func createChallenge(challengeName: String, challengeTemplateID: String, userXPData: XPData) async -> Bool {
        let isoFormatter = ISO8601DateFormatter()

        switch challengeName {
            case "30 Day LevelUp Challenge":
                let levelsRequired = levelsRequired(currentLevel: userXPData.level)
                guard let dateRange = DateUtility.createDateDurationISO(duration: 30) else { return false }

                await updateChallenge(challengeTemplateID: challengeTemplateID, challengeName: challengeName, startDate: dateRange.0, endDate: dateRange.1, startValue: userXPData.level, targetValue: userXPData.level + levelsRequired, field: "Level")

            case "Perfect Program Week":
                if let program = ProgramManager.shared.userProgramData.first?.program {
                    let daysRequired = program.program.count
                    guard let dateRange = DateUtility.createDateDurationISO(duration: 7) else { return false }

                    switch program.getConsecutiveCompletionDays() {
                        case .success(let consecutiveDays):
                            await updateChallenge(challengeTemplateID: challengeTemplateID, challengeName: challengeName, startDate: dateRange.0, endDate: dateRange.1, startValue: consecutiveDays, targetValue: daysRequired, field: "Level")
                            return true
                        case .failure(let error):
                            print("Error calculating consecutive days: \(error.localizedDescription)")
                            return false
                    }
                }
            case "3-in-15 Challenge":
                let levelsRequired = 3
                guard let dateRange = DateUtility.createDateDurationISO(duration: 15) else { return false }

                await updateChallenge(challengeTemplateID: challengeTemplateID, challengeName: challengeName, startDate: dateRange.0, endDate: dateRange.1, startValue: userXPData.level, targetValue: userXPData.level + levelsRequired, field: "Level")
            default:
                break
        }
        return false
    }

    // MARK: - Update Challenge
    func updateChallenge(challengeTemplateID: String, challengeName: String, startDate: String, endDate: String, startValue: Int, targetValue: Int, field: String) async {
        do {
            let userID = try await ChallengeCloudKitUtility.customContainer.userRecordID().recordName

            let userChallenge = UserChallenge(
                userID: userID,
                id: UUID().uuidString,
                challengeTemplateID: challengeTemplateID,
                name: challengeName,
                startDate: startDate,
                endDate: endDate,
                startValue: startValue,
                targetValue: targetValue,
                field: field,
                isFailed: false,
                isActive: true
            )

            await ChallengeCloudKitUtility.saveUserChallenge(userChallenge: userChallenge) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.userChallenges.append(userChallenge)
                    }
                } else if let error = error {
                    print("Error saving challenge: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user record ID: \(error.localizedDescription)")
        }
    }

    // MARK: - Leave Challenge
    func leaveChallenge(challengeTemplateID: String) async {
        do {
            let userID = try await ChallengeCloudKitUtility.customContainer.userRecordID().recordName

            await ChallengeCloudKitUtility.leaveChallenge(userID: userID, challengeTemplateID: challengeTemplateID) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.userChallenges.removeAll { $0.challengeTemplateID == challengeTemplateID }
                    }
                } else if let error = error {
                    print("Error leaving challenge: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user record ID: \(error.localizedDescription)")
        }
    }

    // MARK: - Check for Challenge Completion
    func checkForChallengeCompletion(challengeField: String, newValue: Int) async {
        do {
            let userID = try await ChallengeCloudKitUtility.customContainer.userRecordID().recordName

            await ChallengeCloudKitUtility.updateChallengeProgress(userID: userID, field: challengeField, newValue: newValue) { success, error in
                if success {
                    DispatchQueue.main.async {
                        GlobalCoverManager.shared.showChallengeCompletion()
                    }
                } else if let error = error {
                    print("Error updating challenge progress: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error getting user record ID: \(error.localizedDescription)")
        }
    }

    // MARK: - Calculate Levels Required for Challenge
    func levelsRequired(currentLevel: Int, k: Double = 5.0) -> Int {
        let requiredLevels = Int(ceil(k / sqrt(Double(currentLevel))))
        return max(requiredLevels, 1)
    }
}
