//
//  InitializationManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/19/24.
//

import Foundation

class InitializationManager {
    static let shared = InitializationManager()
    
    @Published var selectedAffirmation: String?
    
    let affirmations = [
        "You've got this!",
        "Today is your day!",
        "Small steps, big results!",
        "Believe in yourself!",
        "Every day is a new opportunity!"
    ]
    
    
    var initializationComplete: Bool = false
    func initialize() async {
        if !initializationComplete {
            self.selectedAffirmation = affirmations.randomElement()
            
            async let userProgram: ()? = userProgramInitialization()
            async let notificationManager: () = NotificationManager.shared.identifyUser()
            async let challengeManager: () = ChallengeManager.shared.challengeManagerInitialization()
            async let toDoListManager: () = ToDoListManager.shared.toDoListInit()
            async let exerciseManager: () = ExerciseManager.shared.exerciseManagerInit()
            async let xpManager: () = XPManager.shared.xpManagerInit()
            async let authenticationManager: Bool = AuthenticationManager.shared.getUserData()

            _ = await (authenticationManager, userProgram, notificationManager, challengeManager, toDoListManager, exerciseManager, xpManager)
            
            initializationComplete = true
        }
    }
    
    func userProgramInitialization() async {
        await ProgramManager.shared.userProgramData.isEmpty ? ProgramManager.shared.loadUserProgramData() : nil
        await ProgramManager.shared.loadStandardProgramNamesAsync()
    }
}
