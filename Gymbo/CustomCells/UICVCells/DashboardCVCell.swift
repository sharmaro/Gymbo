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
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.large.bold
        return label
    }()

    private let contentLabel: UILabel = {
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
            titleLabel.top.constraint(
                equalTo: roundedView.top,
                constant: 5),
            titleLabel.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            titleLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            titleLabel.bottom.constraint(
                equalTo: contentLabel.top,
                constant: -10),

            contentLabel.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            contentLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            contentLabel.bottom.constraint(
                lessThanOrEqualTo: roundedView.bottom,
                constant: -5)
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
