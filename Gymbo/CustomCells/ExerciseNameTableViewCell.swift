//
//  ExerciseNameTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/18/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol DeleteExerciseButtonDelegate: class {
    func deleteExerciseButtonTapped(cell: ExerciseNameTableViewCell)
}

class ExerciseNameTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var deleteExerciseButton: CustomButton!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    weak var deleteExerciseButtonDelegate: DeleteExerciseButtonDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
    }

    private func setup() {
        selectionStyle = .none

        exerciseNameLabel.textColor = .blue

        deleteExerciseButton.layer.cornerRadius = deleteExerciseButton.bounds.width / 2
        deleteExerciseButton.clipsToBounds = true
    }

    @IBAction private func deleteExerciseButtonTapped(_ sender: Any) {
        deleteExerciseButtonDelegate?.deleteExerciseButtonTapped(cell: self)
    }
}
