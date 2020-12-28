//
//  DataState.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

enum DataState {
    case editing
    case notEditing

    mutating func toggle() {
        self = self == .editing ? .notEditing : .editing
    }
}
