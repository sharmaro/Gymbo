//
//  CreateEditSessionTVC+ExerciseTVCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: ExerciseTVCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField,
                                           replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 5
    }

    func textFieldDidEndEditing(textField: UITextField,
                                textFieldType: TextFieldType,
                                cell: ExerciseDetailTVCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let indexPathToUse = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        customDataSource?.saveTextFieldsWithOrWithoutRealm(text: textField.text,
                                                           textFieldType: textFieldType,
                                                           indexPath: indexPathToUse)
    }
}
