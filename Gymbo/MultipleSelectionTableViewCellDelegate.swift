//
//  MultipleSelectionTableViewCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

protocol MultipleSelectionTableViewCellDelegate: class {
    func selected(items: [String])
}