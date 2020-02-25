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

struct ExerciseHeaderTableViewCellModel {
    var name: String?
    var isDoneButtonImageHidden = false
}

class ExerciseHeaderTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private weak var exerciseNameLabel: UILabel!
    @IBOutlet private weak var deleteExerciseButton: CustomButton!
    // Exercise title views
    @IBOutlet private weak var setsLabel: UILabel!
    @IBOutlet private weak var lastLabel: UILabel!
    @IBOutlet private weak var repsLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private var isDoneButtonImageHidden = false {
        didSet {
            let image = isDoneButtonImageHidden ? nil : UIImage(named: "checkmark")
            let text = isDoneButtonImageHidden ? "-" : nil

            doneButton.setImage(image, for: .normal)
            doneButton.setTitle(text, for: .normal)
            doneButton.isUserInteractionEnabled = isDoneButtonImageHidden
        }
    }

    weak var exerciseHeaderCellDelegate: ExerciseHeaderCellDelegate?
}

// MARK: - UITableViewCell Var/Funcs
extension ExerciseHeaderTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        setup()
        setupTextFields()
    }
}

// MARK: - Funcs
extension ExerciseHeaderTableViewCell {
    private func setup() {
        selectionStyle = .none

        exerciseNameLabel.textColor = .blue

        deleteExerciseButton.roundCorner(radius: deleteExerciseButton.bounds.width / 2)

        doneButton.setTitleColor(.black, for: .normal)
    }

    private func setupTextFields() {
        setsLabel.text = "Set"
        lastLabel.text = "Last"
        repsLabel.text = "Reps"
        weightLabel.text = "Lbs"
    }

    func configure(dataModel: ExerciseHeaderTableViewCellModel) {
        exerciseNameLabel.text = dataModel.name
        isDoneButtonImageHidden = dataModel.isDoneButtonImageHidden
    }

    @IBAction func deleteExerciseButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.deleteExerciseButtonTapped(cell: self)
    }
}
