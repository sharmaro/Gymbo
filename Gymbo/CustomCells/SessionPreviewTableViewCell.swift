//
//  SessionPreviewTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/24/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class SessionPreviewTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var exerciseMusclesLabel: UILabel!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return "SessionPreviewTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        exerciseNameLabel.textColor = .black
        exerciseMusclesLabel.textColor = .darkGray
    }

    func clearLabels() {
        exerciseNameLabel.text?.removeAll()
        exerciseMusclesLabel.text?.removeAll()
    }
}
