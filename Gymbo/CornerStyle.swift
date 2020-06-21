//
//  CornerStyle.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//
import UIKit

enum CornerStyle {
    case none
    case xSmall
    case small
    case medium
    case circle(length: CGFloat)

    var radius: CGFloat {
        switch self {
        case .none:
            return 0
        case .xSmall:
            return 5
        case .small:
            return 10
        case .medium:
            return 20
        case .circle(let length):
            return length / 2
        }
    }
}
