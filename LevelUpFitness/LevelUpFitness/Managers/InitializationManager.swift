//
//  InitializationManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/19/24.
//

import Foundation

class InitializationManager {
    static let shared = InitializationManager()
    
    var initializationComplete: Bool = false
    func initialize() async {
        if !initializationComplete {
            if await HealthManager.shared.todaysSteps == nil {
                await HealthManager.shared.getInitialHealthData()
            }
                
            async let userProgram: ()? = ProgramManager.shared.userProgramData.isEmpty ? ProgramManager.shared.loadUserProgramData() : nil
            async let notificationManager: () = NotificationManager.shared.identifyUser()
            async let challengeManager: () = ChallengeManager.shared.challengeManagerInitialization()
            async let toDoListManager: () = ToDoListManager.shared.toDoListInit()
            async let exerciseManager: () = ExerciseManager.shared.exerciseManagerInit()
            async let xpManager: () = XPManager.shared.xpManagerInit()
            
    //                async let getUsername: () = AuthenticationManager.getUsername()
    //                async let getName: () = AuthenticationManager.getName()
    //
            _ = await (userProgram, notificationManager, challengeManager, toDoListManager, exerciseManager, xpManager)
            
            initializationComplete = true
        }
    }
}
