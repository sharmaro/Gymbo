//
//  StartedSessionTVC+ExerciseTVCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartedSessionTVC: ExerciseTVCellDelegate {
    private enum Constants {
        static let characterLimit = 5
    }

    func shouldChangeCharactersInTextField(textField: UITextField,
                                           replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count <= Constants.characterLimit
    }

    func textFieldDidEndEditing(textField: UITextField,
                                textFieldType: TextFieldType,
                                cell: ExerciseDetailTVCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let text = textField.text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise header cell
        customDataSource?.saveTextFieldData(text,
                                            textFieldType: textFieldType,
                                            section: indexPath.section,
                                            row: indexPath.row - 1)
    }
}
