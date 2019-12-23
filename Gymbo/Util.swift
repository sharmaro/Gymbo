//
//  Util.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/12/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation

enum SessionDetailType {
    case name
    case sets
    case reps(areUnique: Bool)
    case weight
    case time
    case info

    func valueForType() -> String {
        let value: String
        switch self {
        case .name:
            value = "name"
        case .sets:
            value = "sets"
        case .reps:
            value = "reps"
        case .weight:
            value = "weight"
        case .time:
            value = "time"
        case .info:
            value = "additional info"
        }
        return value
    }
}

struct Util {
    static func formattedString(stringToFormat string: String?, type: SessionDetailType) -> String {
        guard let string = string, string.count > 0 else {
            return "--"
        }

        var suffix = ""
        switch type {
        case .name:
            return string
        case .sets:
            suffix = Util.formatPluralString(inputString: string, suffixBase: "set")
        case .reps(let areUnique):
            if areUnique {
                return "unique reps"
            }

            suffix = Util.formatPluralString(inputString: string, suffixBase: "rep")
        case .weight:
            suffix = Util.formatPluralString(inputString: string, suffixBase: "lb")
        case .time:
            suffix = Util.formatPluralString(inputString: string, suffixBase: "sec")
        case .info:
            suffix = ""
        }
        return "\(string) \(suffix)"
    }

    private static func formatPluralString(inputString: String, suffixBase: String) -> String {
        let isDouble = inputString.contains(".")

        let correctSuffix: String

        if isDouble {
            if let doubleValue = Double(inputString), doubleValue != 0 {
                correctSuffix = doubleValue > 1 ? "\(suffixBase)s" : suffixBase
            } else {
                correctSuffix = "0 \(suffixBase)s"
            }
        } else {
            if let intValue = Int(inputString), intValue != 0 {
                correctSuffix = intValue > 1 ? "\(suffixBase)s" : suffixBase
            } else {
                correctSuffix = "\(suffixBase)s"
            }
        }
        return correctSuffix
    }
}
