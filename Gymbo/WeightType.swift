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
}
