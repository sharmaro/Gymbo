//
//  CreateEditSessionTVC+ExerciseHeaderCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: ExerciseHeaderCellDelegate {
    func deleteButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        customDataSource?.deleteExerciseRealm(at: section)
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }

    func weightButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let index = tableView.indexPath(for: cell)?.section else {
            return
        }
        Haptic.sendSelectionFeedback()

        customDataSource?.updateExerciseWeightTypeRealm(at: index,
                                                        weightType: cell.weightType)
    }

    func doneButtonTapped(cell: ExerciseHeaderTVCell) {
        // No op
    }
}
