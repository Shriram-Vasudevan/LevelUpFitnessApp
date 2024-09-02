//
//  NotificationManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/15/24.
//

import Foundation
import UserNotifications
import Amplify

struct NotificationManager {
    static let shared = NotificationManager()
    
    init() {
        askPermission()
        
    }
    
    func identifyUser() async {
        do {
            let user = try await Amplify.Auth.getCurrentUser().userId
            try await Amplify.Notifications.Push.identifyUser(userId: user)
        } catch {
            print("Failed to get userID: \(error)")
        }
    }
    
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Access granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleMorningNotification() {
        let calendar = Calendar.current
        
        guard let tomorrowsDate = calendar.date(byAdding: .day, value: 1, to: Date()) else { return }
        var tomorrowsDateComponents = calendar.dateComponents([.year, .hour, .minute], from: tomorrowsDate)
        
        tomorrowsDateComponents.hour = 8
        tomorrowsDateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "Ready for Today?"
        content.body = "Time to Move!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: tomorrowsDateComponents, repeats: false)

        let request = UNNotificationRequest(identifier: "MorningNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }
    
    func scheduleInactiveNotification() {
        let timeInterval: TimeInterval = 24 * 60 * 60
        
        let content = UNMutableNotificationContent()
        content.title = "We miss you!"
        content.body = "Come back and get to Work!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        let request = UNNotificationRequest(identifier: "InactiveNotification", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }
    
    func cancelMorningNotification() {
        print("Cancelling morning notification")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["MorningNotification"])
    }
    
    func cancelInactiveNotification() {
        print("Cancelling inactive notification")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["InactiveNotification"])
    }
    
    func appDidEnterBackground() {
        UserDefaults.standard.set(Date(), forKey: "LastActiveTime")
        scheduleInactiveNotification()
        scheduleMorningNotification()
    }
    
    func appDidBecomeActive() {
        cancelInactiveNotification()
        cancelMorningNotification()
    }
}
