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
    static let shared = NotificationHelper()

    private let notificationCenter = UNUserNotificationCenter.current()
    private let options: UNAuthorizationOptions = [.alert, .sound, .badge]

    override init() {
        super.init()

        notificationCenter.delegate = self
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
    func requestPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] (settings) in
            guard let self = self else { return }

            if settings.authorizationStatus == .notDetermined || settings.authorizationStatus == .denied {
                self.notificationCenter.requestAuthorization(options: self.options) { (didAllow, _) in
                    if didAllow {
                        print("User accepted notifications :)")
                    } else {
                        print("User declined notifications :(")
                    }
                }
            }
        }
    }

    func sendNotification() {
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

    func removeAllPendingNotificationRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func clearBadgeNumber() {
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
