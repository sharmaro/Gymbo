//
//  Notification+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK - Notification
extension Notification {
    var keyboardSize: CGSize? {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    }

    var keyboardAnimationDuration: Double? {
        userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }
}

// MARK - Notification.Name
extension Notification.Name {
    // Sessions
    static let updateSessionsUI = Notification.Name("updateSessionsUI")
    static let reloadDataWithoutAnimation = Notification.Name("reloadDataWithoutAnimation")
    static let startSession = Notification.Name("startSession")
    static let endSession = Notification.Name("endSession")

    // Exercises
    static let updateExercisesUI = Notification.Name("updateExercisesUI")
}
