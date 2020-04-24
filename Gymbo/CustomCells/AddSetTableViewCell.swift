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

    private var addSetButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.title = "+ Set"
        button.titleFontSize = 15
        button.add(backgroundColor: .lightGray)
        button.addCorner()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    weak var addSetTableViewCellDelegate: AddSetTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addMainViews()
        setupAddSetButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addMainViews()
        setupAddSetButton()
    }
}

// MARK: - Funcs
extension AddSetTableViewCell {
    private func addMainViews() {
        selectionStyle = .none

        addSubviews(views: [addSetButton])
    }

    private func setupAddSetButton() {
        addSetButton.addTarget(self, action: #selector(addSetButtonTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            addSetButton.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            addSetButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addSetButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addSetButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }

    @objc private func addSetButtonTapped(_ sender: Any) {
        addSetTableViewCellDelegate?.addSetButtonTapped(cell: self)
    }
}
