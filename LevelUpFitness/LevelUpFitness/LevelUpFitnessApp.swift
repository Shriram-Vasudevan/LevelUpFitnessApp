//
//  LevelUpFitnessApp.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/7/24.
//

import SwiftUI
import Amplify
import AWSS3StoragePlugin
import AWSCognitoAuthPlugin
import AWSAPIPlugin

@main
struct LevelUpFitnessApp: App {
    //@StateObject private var authStateObserver = AuthStateObserver()

    init() {
        configureAmplify { success in
            if success {
                //authStateObserver.checkAuthState()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }

    private func configureAmplify(completionHandler: @escaping (Bool) -> Void) {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
            completionHandler(true)
        } catch {
            print("could not initialize Amplify", error)
            completionHandler(false)
        }
    }
}
