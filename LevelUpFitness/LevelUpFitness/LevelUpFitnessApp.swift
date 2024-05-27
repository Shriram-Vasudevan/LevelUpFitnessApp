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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authStateObserver = AuthStateObserver()

    var body: some Scene {
        WindowGroup {
            AuthCheckView()
                .environmentObject(authStateObserver)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        return true
    }
}

