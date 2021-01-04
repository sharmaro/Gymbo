//
//  WeightType.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

enum WeightType: Int, CaseIterable {
    case lbs
    case kgs

    var text: String {
        switch self {
        case .lbs:
            return "Lbs"
        case .kgs:
            return "Kgs"
        }
    }

    var settingsText: String {
        let response: String
        switch self {
        case .lbs:
            response = "US/Imperial (\(text))"
        case .kgs:
            response = "Metric (\(text))"
        }
        return response
    }

    static var textItems: [String] {
        WeightType.allCases.map {
            $0.text
        }
    }

    static func type(text: String) -> Int {
        switch text {
        case "Lbs":
            return WeightType.lbs.rawValue
        case "Kgs":
            return WeightType.kgs.rawValue
        default:
            return -1
        }
    }

    static func rawValue(from settingsText: String) -> Int {
        var response = 0
        if settingsText == WeightType.lbs.settingsText {
            response = 0
        } else if settingsText == WeightType.kgs.settingsText {
            response = 1
        }
        return response
    }
}
