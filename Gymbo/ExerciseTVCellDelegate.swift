//
//  ExerciseTVCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ExerciseTVCellDelegate: class {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool
    func textFieldDidEndEditing(textField: UITextField,
                                textFieldType: TextFieldType,
                                cell: ExerciseDetailTVCell)
}
