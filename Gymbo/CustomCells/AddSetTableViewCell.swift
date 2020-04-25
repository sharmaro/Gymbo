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

// MARK: - Properties
class AddSetTableViewCell: UITableViewCell {
    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private var addSetButton = CustomButton(frame: .zero)

    weak var addSetTableViewCellDelegate: AddSetTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ViewAdding
extension AddSetTableViewCell: ViewAdding {
    func addViews() {
        add(subViews: [addSetButton])
    }

    func setupViews() {
        selectionStyle = .none

        addSetButton.title = "+ Set"
        addSetButton.titleLabel?.font = .small
        addSetButton.add(backgroundColor: .lightGray)
        addSetButton.addCorner(style: .small)
        addSetButton.addTarget(self, action: #selector(addSetButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            addSetButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            addSetButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addSetButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addSetButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - Funcs
extension AddSetTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    @objc private func addSetButtonTapped(_ sender: Any) {
        addSetTableViewCellDelegate?.addSetButtonTapped(cell: self)
    }
}
