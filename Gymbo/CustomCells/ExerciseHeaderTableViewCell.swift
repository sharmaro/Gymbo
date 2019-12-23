//
//  ExerciseNameTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/18/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ExerciseHeaderCellDelegate: class {
    func deleteExerciseButtonTapped(cell: ExerciseHeaderTableViewCell)
}

class ExerciseHeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var deleteExerciseButton: CustomButton!

    // Exercise title views
    @IBOutlet private weak var setsLabel: UILabel!
    @IBOutlet private weak var lastLabel: UILabel!
    @IBOutlet private weak var repsLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    weak var exerciseHeaderCellDelegate: ExerciseHeaderCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
        setupTextFields()
    }

    private func setup() {
        selectionStyle = .none

        exerciseNameLabel.textColor = .blue

        deleteExerciseButton.clipsToBounds = true
        deleteExerciseButton.layer.cornerRadius = deleteExerciseButton.bounds.width / 2
    }

    private func setupTextFields() {
        setsLabel.text = "Set"
        lastLabel.text = "Last"
        repsLabel.text = "Reps"
        weightLabel.text = "Lbs"
    }

    @IBAction func deleteExerciseButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.deleteExerciseButtonTapped(cell: self)
    }
}
