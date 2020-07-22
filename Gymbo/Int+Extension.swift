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

    func twoDigits() -> String {
        String(format: "%02d", self)
    }

    func getMinutesAndSecondsString() -> String {
        let minutes = (self / 60).twoDigits()
        let seconds = (self % 60).twoDigits()
        return "\(minutes):\(seconds)"
    }
}
