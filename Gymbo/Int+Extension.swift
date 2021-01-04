//
//  Int+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension Int {
    var cgFloat: CGFloat {
        CGFloat(self)
    }

    var twoDigitsString: String {
        String(format: "%02d", self)
    }

    var minutesAndSecondsString: String {
        let minutes = (self / 60).twoDigitsString
        let seconds = (self % 60).twoDigitsString
        return "\(minutes):\(seconds)"
    }

    var neatTimeString: String {
        let response: String
        if self < 60 {
            response = "\(self)s"
        } else if self >= 60 && self < 3600 {
            let minutes = self / 60
            let seconds = self % 60
            response = "\(minutes)m \(seconds)s"
        } else {
            let hours = self / 3600
            let minutesInSeconds = self % 3600
            let minutes = minutesInSeconds / 60
            response = "\(hours)h \(minutes)m"
        }
        return response
    }
}
