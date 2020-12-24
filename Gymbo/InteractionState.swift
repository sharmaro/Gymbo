//
//  InteractionState.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

enum InteractionState {
    case enabled
    case disabled

    static func stateFromBool(_ bool: Bool) -> InteractionState {
        bool ? enabled : disabled
    }
}
