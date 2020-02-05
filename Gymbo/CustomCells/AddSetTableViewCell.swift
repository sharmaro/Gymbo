//
//  AddSetTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/14/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol AddSetTableViewCellDelegate: class {
    func addSetButtonTapped(cell: AddSetTableViewCell)
}

class AddSetTableViewCell: UITableViewCell {
    // MARK: - Properties
    @IBOutlet private weak var addSetButton: CustomButton!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    weak var addSetTableViewCellDelegate: AddSetTableViewCellDelegate?
}

// MARK: - UITableViewCell Var/Funcs
extension AddSetTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupAddSetButton()
    }
}

// MARK: - Funcs
extension AddSetTableViewCell {
    private func setupAddSetButton() {
        addSetButton.titleFontSize = 15
        addSetButton.add(backgroundColor: .lightGray)
        addSetButton.addCornerRadius()
    }

    @IBAction func addSetButtonTapped(_ sender: Any) {
        addSetTableViewCellDelegate?.addSetButtonTapped(cell: self)
    }
}
