//
//  KeyboardObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol KeyboardObserving: AnyObject {
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
        _ = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillShowNotification,
        object: nil,
        queue: nil) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }

        _ = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardDidShowNotification,
        object: nil,
        queue: nil) { [weak self] notification in
            self?.keyboardDidShow(notification)
        }

        _ = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillHideNotification,
        object: nil,
        queue: nil) { [weak self] notification in
            self?.keyboardWillHide(notification)
        }

        _ = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardDidHideNotification,
        object: nil,
        queue: nil) { [weak self] notification in
            self?.keyboardDidHide(notification)
        }

        _ = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardWillChangeFrameNotification,
        object: nil,
        queue: nil) { [weak self] notification in
            self?.keyboardWillChangeFrame(notification)
        }

        _ = NotificationCenter.default.addObserver(
        forName: UIResponder.keyboardDidChangeFrameNotification,
        object: nil,
        queue: nil) { [weak self] notification in
            self?.keyboardDidChangeFrame(notification)
        }
    }
}
