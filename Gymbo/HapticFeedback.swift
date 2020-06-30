//
//  HapticFeedback.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/21/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

enum HapticStyle {
//    case
}

// MARK: - Properties
struct Haptic {
    static let shared = Haptic()
}

// MARK: - Structs/Enums
private extension Haptic {
    struct Constants {
    }
}

// MARK: - Funcs
extension Haptic {
    func test() {
        let t = UINotificationFeedbackGenerator()
        let l = UIImpactFeedbackGenerator()
    }
}
