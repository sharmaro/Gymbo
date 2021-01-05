//
//  CreateEditExerciseTVC+ListDataSource.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditExerciseTVC: ListDataSource {
    func cellForRowAt(tvCell: UITableViewCell) {
        if let textFieldTVCell = tvCell as? TextFieldTVCell {
            textFieldTVCell.customTextFieldDelegate = self
        } else if let multipleSelectionTVCell = tvCell as? MultipleSelectionTVCell {
            multipleSelectionTVCell.multipleSelectionTVCellDelegate = self
        } else if let imagesTVCell = tvCell as? ImagesTVCell {
            imagesTVCell.imageButtonDelegate = self
        } else if let textViewTVCell = tvCell as? TextViewTVCell {
            textViewTVCell.customTextViewDelegate = self
        }
    }
}
