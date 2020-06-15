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
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }()

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
extension LabelTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [detailLabel])
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: topAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension LabelTableViewCell {
    private func setup() {
        addViews()
        addConstraints()
    }

    func configure(text: String, font: UIFont = .normal) {
        detailLabel.text = text
        detailLabel.font = font
    }
}
