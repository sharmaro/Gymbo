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
}
