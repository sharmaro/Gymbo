//
//  DashboardCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/31/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DashboardCVCell: RoundedCVCell {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.large.bold
        return label
    }()

    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normal.light
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension DashboardCVCell {
}

// MARK: - UIView Var/Funcs
extension DashboardCVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension DashboardCVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [titleLabel, contentLabel])
    }

    func setupColors() {
        titleLabel.textColor = .primaryText
        contentLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: roundedView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -10),

            contentLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: roundedView.bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Funcs
extension DashboardCVCell {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
}
