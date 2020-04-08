//
//  ExerciseTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseTableViewCell: UITableViewCell {
    @IBOutlet private weak var exerciseNameLabel: UILabel!
    @IBOutlet private weak var exerciseMusclesLabel: UILabel!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private var isUserMade = false {
        didSet {
            backgroundColor = isUserMade ? .systemBlue : .white
        }
    }

    var exerciseName: String? {
        return exerciseNameLabel.text
    }

    var didSelect = false {
        didSet {
            let defaultColor: UIColor = isUserMade ? .systemBlue : .white
            backgroundColor = didSelect ? .systemGray : defaultColor
        }
    }
}

// MARK: - UITableViewCell Var/Funcs
extension ExerciseTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        exerciseNameLabel.textColor = .black
        exerciseMusclesLabel.textColor = .darkGray
    }
}

// MARK: - Funcs
extension ExerciseTableViewCell {
    func configure(dataModel: ExerciseText) {
        exerciseNameLabel.text = dataModel.exerciseName
        exerciseMusclesLabel.text = dataModel.exerciseMuscles
        isUserMade = dataModel.isUserMade
    }
}
