//
//  PickerDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/10/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import Foundation

protocol PickerDelegate: class {
    func canceledSelection()
    func selected(row: Int)
}

extension PickerDelegate {
    func canceledSelection() {}
}
