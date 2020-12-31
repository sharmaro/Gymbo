//
//  CreateEditSessionTVC+ButtonTVCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: ButtonTVCellDelegate {
    func buttonTapped(cell: ButtonTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section,
              let customDataSource = customDataSource else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        customDataSource.addSetRealm(section: section)
        customDataSource.didAddSet = true
        let numberOfRows = tableView.numberOfRows(inSection: section)
        let indexPath = IndexPath(row: numberOfRows - 2, section: section)
        if let exerciseDetailCell = tableView.cellForRow(at: indexPath) as? ExerciseDetailTVCell {
            let previousReps = exerciseDetailCell.reps
            let previousWeight = exerciseDetailCell.weight
            customDataSource.previousExerciseDetailInformation = (previousReps,
                                                                  previousWeight)
            /*
             - Saving info in previously filled out ExerciseDetailTVCell in case the data wasn't saved
             - Usually it's saved when the textField resigns first responder
             - But if the user adds a set and doesn't resign the reps or weight textField first,
             then the data has to be manually saved by calling saveTextFieldsWithOrWithoutRealm()
             */
            customDataSource.saveTextFieldsWithOrWithoutRealm(text: previousReps,
                                                              textFieldType: .reps,
                                                              indexPath: indexPath)
            customDataSource.saveTextFieldsWithOrWithoutRealm(text: previousWeight,
                                                              textFieldType: .weight,
                                                              indexPath: indexPath)
        }

        DispatchQueue.main.async { [weak self] in
            let sets = customDataSource
                .session.exercises[section].sets
            let lastIndexPath = IndexPath(row: sets, section: section)

            self?.tableView.insertRows(at: [lastIndexPath], with: .automatic)
            // Scrolling to addSetButton row
            self?.tableView.scrollToRow(
                at: IndexPath(row: sets, section: section),
                at: .top,
                animated: true)
        }
        view.endEditing(true)
    }
}
