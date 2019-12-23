//
//  ExerciseTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseMusclesLabel: UILabel!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        exerciseNameLabel.textColor = .black
        exerciseMusclesLabel.textColor = .darkGray
    }
}