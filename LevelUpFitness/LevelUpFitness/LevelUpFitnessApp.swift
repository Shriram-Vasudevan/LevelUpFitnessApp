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

import UIKit
import UserNotifications
import AWSPinpointPushNotificationsPlugin

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.add(plugin: AWSPinpointPushNotificationsPlugin(options: [.badge, .alert, .sound]))
            try Amplify.configure()
            print("Amplify configured successfully")
            
            #if targetEnvironment(simulator)
                if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
                    print("Documents Directory: \(documentsPath)")
                }
            #endif
            
            NotificationManager.shared.askPermission()
            
        } catch {
            print("An error occurred setting up Amplify: \(error)")
        }
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task {
            do {
                try await Amplify.Notifications.Push.registerDevice(apnsToken: deviceToken)
                print("Registered with Pinpoint.")
                print("Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
            } catch {
                print("Error registering with Pinpoint: \(error)")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) async -> UIBackgroundFetchResult {
        
        do {
            try await Amplify.Notifications.Push.recordNotificationReceived(userInfo)
        } catch {
            print("Error recording receipt of notification: \(error)")
        }
        
        return .newData
    }
}

