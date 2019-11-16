//
//  AddSetTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/14/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol AddSetTableViewCellDelegate: class {
    func addSetButtonTapped(section: Int)
}

class AddSetTableViewCell: UITableViewCell {
    @IBOutlet weak var addSetButton: CustomButton!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return "AddSetTableViewCell"
    }

    var section: Int?

    weak var addSetTableViewCellDelegate: AddSetTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupAddSetButton()
    }

    private func setupAddSetButton() {
        addSetButton.addCornerRadius()
        addSetButton.tag = section ?? -1
    }

    @IBAction func addSetButtonTapped(_ sender: Any) {
        guard sender is CustomButton else {
            return
        }

        addSetTableViewCellDelegate?.addSetButtonTapped(section: section ?? -1)
    }
}
