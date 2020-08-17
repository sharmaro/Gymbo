//
//  NotificationHelper.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/17/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import UserNotifications

// MARK: - Properties
class NotificationHelper: NSObject {
    private static let notificationCenter = UNUserNotificationCenter.current()
    private static let options: UNAuthorizationOptions = [.alert, .sound, .badge]

    override init() {
        super.init()

        NotificationHelper.notificationCenter.delegate = self
    }
}

// MARK: - Structs/Enums
private extension NotificationHelper {
    struct Constants {
        static let localIdentifier = "localIdentifier"
    }
}

// MARK: - Funcs
extension NotificationHelper {
    static func requestPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in

            if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                NotificationHelper.notificationCenter.requestAuthorization(
                options: NotificationHelper.options) { (didAllow, _) in
                    if didAllow {
                        print("User accepted notifications :)")
                    } else {
                        print("User declined notifications :(")
                    }
                }
            }
        }
    }

    static func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.subtitle = "Subtitle"
        content.body = "Body"
        content.sound = .default
        content.badge = 1
        content.launchImageName = "empty"
        content.userInfo = [:]
        content.attachments = []

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = Constants.localIdentifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    static func removeAllPendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    static func clearBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationHelper: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.actionIdentifier == UNNotificationDismissActionIdentifier {
            // User dismissed notification without taking action
            // No op
        } else if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // User launched the app
            if response.notification.request.identifier == Constants.localIdentifier {
                // To do
            }
        }
        completionHandler()
    }
}
