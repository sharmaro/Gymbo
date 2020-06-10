//
//  LabelTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class LabelTableViewCell: UITableViewCell {
    private var detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ReuseIdentifying
extension LabelTableViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension LabelTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [detailLabel])
    }

    func setupViews() {
        detailLabel.font = .normal
        detailLabel.numberOfLines = 0
        detailLabel.sizeToFit()
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: topAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Funcs
extension LabelTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(text: String) {
        detailLabel.text = text
    }
}
