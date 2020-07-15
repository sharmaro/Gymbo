//
//  ExerciseHeaderCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

protocol ExerciseHeaderCellDelegate: class {
    func deleteButtonTapped(cell: ExerciseHeaderTableViewCell)
    func weightButtonTapped(cell: ExerciseHeaderTableViewCell)
    func doneButtonTapped(cell: ExerciseHeaderTableViewCell)
}
