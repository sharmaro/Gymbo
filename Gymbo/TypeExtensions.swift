//
//  TypeExtensions.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Int
extension Int {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }

    func twoDigits() -> String {
        return String(format: "%02d", self)
    }

    func getMinutesAndSecondsString() -> String {
        let minutes = (self / 60).twoDigits()
        let seconds = (self % 60).twoDigits()
        return "\(minutes):\(seconds)"
    }
}

// MARK: - String
extension String {
    func getSecondsFromTime() -> Int? {
        let times = Array(self)
        guard times.count == 5 else {
            return nil
        }

        let minutes = Int("\(times[0])\(times[1])") ?? 0
        let seconds = Int("\(times[3])\(times[4])") ?? 0

        return (minutes * 60) + seconds
    }
}

// MARK: - Notification
extension Notification {
    var keyboardSize: CGSize? {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
    }

    var keyboardAnimationDuration: Double? {
        return userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
    }
}

// MARK: - Notification.Name
extension Notification.Name {
    // Sessions
    static let updateSessionsUI = Notification.Name("updateSessionsUI")
    static let startSession = Notification.Name("startSession")
    static let endSession = Notification.Name("endSession")

    // Exercises
    static let updateExercisesUI = Notification.Name("updateExercisesUI")
}
