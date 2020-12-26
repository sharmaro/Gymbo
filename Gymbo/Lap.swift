//
//  Lap.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

// Codable is for encoding/decoding
// MARK: - Properties
//swiftlint:disable:next type_name
struct Lap: Codable {
    var minutes: Int
    var seconds: Int
    var centiSeconds: Int

    var totalTime: Int {
        let minutesConverted = minutes * 6000
        let secondsConverted = seconds * 100
        return minutesConverted + secondsConverted + centiSeconds
    }

    var text: String {
        let minuteText = String(format: "%02d", minutes)
        let secondsText = String(format: "%02d", seconds)
        let centiSecondsText = String(format: "%02d", centiSeconds)
        return "\(minuteText):\(secondsText).\(centiSecondsText)"
    }
}
