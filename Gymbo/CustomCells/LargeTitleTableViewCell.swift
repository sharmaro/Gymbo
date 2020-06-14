//
//  LargeTitleTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class LargeTitleTableViewCell: UITableViewCell {
    private var largeTitleLabel = LargeTitleLabel()

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
extension LargeTitleTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [largeTitleLabel])
    }

    func setupViews() {
        selectionStyle = .none
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            largeTitleLabel.topAnchor.constraint(equalTo: topAnchor),
            largeTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            largeTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            largeTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Funcs
extension LargeTitleTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(title: String) {
        largeTitleLabel.text = title
    }
}
