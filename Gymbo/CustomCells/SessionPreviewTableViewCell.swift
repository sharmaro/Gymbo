//
//  SessionPreviewTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/24/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct SessionPreviewTableViewCellModel {
    var name: String? = nil
    var muscles: String? = nil
}

class SessionPreviewTableViewCell: UITableViewCell {
    @IBOutlet private weak var exerciseNameLabel: UILabel!
    @IBOutlet private weak var exerciseMusclesLabel: UILabel!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        exerciseNameLabel.textColor = .black
        exerciseMusclesLabel.textColor = .darkGray
    }

    func configure(dataModel: SessionPreviewTableViewCellModel) {
        exerciseNameLabel.text = dataModel.name
        exerciseMusclesLabel.text = dataModel.muscles
    }
}
