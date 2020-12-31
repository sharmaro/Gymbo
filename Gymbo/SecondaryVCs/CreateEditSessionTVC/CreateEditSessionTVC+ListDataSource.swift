//
//  CreateEditSessionTVC+ListDataSource.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: ListDataSource {
    func cellForRowAt(tvCell: UITableViewCell) {
        if let exerciseHeaderTVCell = tvCell as? ExerciseHeaderTVCell {
            exerciseHeaderTVCell.exerciseHeaderCellDelegate = self
        } else if let buttonTVCell = tvCell as? ButtonTVCell {
            buttonTVCell.buttonTVCellDelegate = self
        } else if let exerciseDetailTVCell = tvCell as? ExerciseDetailTVCell {
            exerciseDetailTVCell.exerciseTVCellDelegate = self
        }
    }
}
