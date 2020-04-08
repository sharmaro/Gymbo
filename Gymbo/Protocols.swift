//
//  Protocols.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/9/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - KeyboardObserving
protocol KeyboardObserving: class {
    func keyboardWillShow(_ notification: Notification)
    func keyboardDidShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
    func keyboardDidHide(_ notification: Notification)
    func keyboardWillChangeFrame(_ notification: Notification)
    func keyboardDidChangeFrame(_ notification: Notification)
    func registerForKeyboardNotifications()
}

extension KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {}
    func keyboardDidShow(_ notification: Notification) {}
    func keyboardWillHide(_ notification: Notification) {}
    func keyboardDidHide(_ notification: Notification) {}
    func keyboardWillChangeFrame(_ notification: Notification) {}
    func keyboardDidChangeFrame(_ notification: Notification) {}

    // Register for UIKeyboard notifications.
    func registerForKeyboardNotifications() {
        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardDidShow(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillHide(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardDidHide(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardWillChangeFrame(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidChangeFrameNotification, object: nil, queue: nil) { [weak self] notification in
            self?.keyboardDidChangeFrame(notification)
        }
    }
}

// MARK: - ApplicationStateObserving
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

// MARK: - SessionProgressObserving
protocol SessionProgressObserving: class {
    func sessionDidStart(_ notification: Notification)
    func sessionDidEnd(_ notification: Notification)
    func registerForSessionProgressNotifications()
}

extension SessionProgressObserving {
    func sessionDidStart(_ notification: Notification) {}
    func sessionDidEnd(_ notification: Notification) {}

    // Register for Session progress notifications.
    func registerForSessionProgressNotifications() {
        _ = NotificationCenter.default.addObserver(forName: .startSession, object: nil, queue: nil) { [weak self] notification in
            self?.sessionDidStart(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: .endSession, object: nil, queue: nil) { [weak self] notification in
            self?.sessionDidEnd(notification)
        }
    }
}
