//
//  Utility.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

// MARK: - Properties
struct Utility {
}

// MARK: - Funcs
extension Utility {
    static func formattedString(stringToFormat string: String?, type: SessionDetailType) -> String {
        guard let string = string,
            !string.isEmpty else {
            return "--"
        }

        var suffix = ""
        switch type {
        case .name:
            return string
        case .sets:
            suffix = Utility.formatPluralString(inputString: string, suffixBase: "set")
        case .reps(let areUnique):
            if areUnique {
                return "unique reps"
            }

            suffix = Utility.formatPluralString(inputString: string, suffixBase: "rep")
        case .weight:
            suffix = Utility.formatPluralString(inputString: string, suffixBase: "lb")
        case .time:
            suffix = Utility.formatPluralString(inputString: string, suffixBase: "sec")
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

    static func getStringArraySeparated(by separator: String, text: String?) -> [String] {
        guard let text = text else {
            return []
        }

        if !text.contains(separator) {
            return text.components(separatedBy: " ")
        } else {
            let stringArray = text.components(separatedBy: ",").map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            return stringArray
        }
    }
}
