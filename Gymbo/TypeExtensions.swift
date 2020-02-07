//
//  TypeExtensions.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation
import UIKit

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

extension Notification.Name {
    static let refreshSessions = Notification.Name("refreshSessions")
}
