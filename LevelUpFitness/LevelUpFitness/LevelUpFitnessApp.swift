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
    @State private var showIntroView = FirstLaunchManager.shared.isFirstLaunch
    
    var body: some Scene {
        WindowGroup {
            if showIntroView {
                IntroView(onIntroCompletion: {
                    FirstLaunchManager.shared.markAsLaunched()
                    showIntroView = false
                })
            } else {
                NavigationStack {
                    PagesHolderView(pageType: .home)
                }
            }
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
                
                await associateUserWithDevice()
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

func associateUserWithDevice() async {
    do {
        let user = try await Amplify.Auth.getCurrentUser().userId
        let userProfile = BasicUserProfile(
            name: "Name",
            customProperties: [
                "attribute": "value"
            ]
        )

        try await Amplify.Notifications.Push.identifyUser(
            userId: user,
            userProfile: userProfile
        )
    } catch {
        print("Error updating endpoint with user information: \(error)")
    }
}
