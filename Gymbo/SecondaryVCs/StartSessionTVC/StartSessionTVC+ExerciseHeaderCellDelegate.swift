//
//  StartSessionTVC+ExerciseHeaderCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartSessionTVC: ExerciseHeaderCellDelegate {
    func deleteButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        customDataSource?.removeExercise(at: section)
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
        // Update SessionsCVC
        NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
    }

    func weightButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        Haptic.sendSelectionFeedback()

        customDataSource?.updateWeightType(type: cell.weightType,
                                           at: indexPath.section)
    }

    func doneButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        let rows = tableView.numberOfRows(inSection: section)
        for i in 0..<rows {
            let indexPath = IndexPath(row: i, section: section)
            if let cell = tableView.cellForRow(at: indexPath) as? ExerciseDetailTVCell {
                customDataSource?.selectedRows.insert(indexPath)
                cell.didSelect = true
            }
        }
    }
}
