//
//  ExerciseTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct ExerciseTableViewCellModel {
    var name: String?
    var muscles: String?
}

class ExerciseTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private weak var exerciseNameLabel: UILabel!
    @IBOutlet private weak var exerciseMusclesLabel: UILabel!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }
}

// MARK: - UITableViewCell Var/Funcs
extension ExerciseTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        exerciseNameLabel.textColor = .black
        exerciseMusclesLabel.textColor = .darkGray
    }
}

// MARK: - Funcs
extension ExerciseTableViewCell {
    func configure(dataModel: ExerciseTableViewCellModel) {
        exerciseNameLabel.text = dataModel.name
        exerciseMusclesLabel.text = dataModel.muscles
    }
}
