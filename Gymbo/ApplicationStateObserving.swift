//
//  ApplicationStateObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ApplicationStateObserving: class {
    func didFinishLaunching(_ notification: Notification)
    func willResignActive(_ notification: Notification)
    func didEnterBackground(_ notification: Notification)
    func willEnterForeground(_ notification: Notification)
    func didBecomeActive(_ notification: Notification)
    func willTerminate(_ notification: Notification)
    func registerForApplicationStateNotifications()
}

extension ApplicationStateObserving where Self: UIViewController {
    func didFinishLaunching(_ notification: Notification) {}
    func willResignActive(_ notification: Notification) {}
    func didEnterBackground(_ notification: Notification) {}
    func willEnterForeground(_ notification: Notification) {}
    func didBecomeActive(_ notification: Notification) {}
    func willTerminate(_ notification: Notification) {}

    // Register for UIApplication state notifications.
    func registerForApplicationStateNotifications() {
        _ = NotificationCenter.default.addObserver(forName: UIApplication.didFinishLaunchingNotification, object: nil, queue: nil) { [weak self] notification in
            self?.didFinishLaunching(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] notification in
            self?.willResignActive(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self] notification in
            self?.didEnterBackground(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: nil) { [weak self] notification in
            self?.willEnterForeground(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] notification in
            self?.didBecomeActive(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: nil) { [weak self] notification in
            self?.willTerminate(notification)
        }
    }
}
