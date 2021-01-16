//
//  StopwatchTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/15/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchTVCell: RoundedTVCell {
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .medium
        label.textAlignment = .left
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .medium
        label.textAlignment = .justified
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension StopwatchTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension StopwatchTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [descriptionLabel, valueLabel])
    }

    func setupColors() {
        [descriptionLabel, valueLabel].forEach { $0.textColor = .primaryText }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.top.constraint(equalTo: roundedView.top),
            descriptionLabel.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            descriptionLabel.bottom.constraint(equalTo: roundedView.bottom),

            valueLabel.top.constraint(equalTo: roundedView.top),
            valueLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            valueLabel.bottom.constraint(equalTo: roundedView.bottom),
            valueLabel.width.constraint(equalToConstant: 90)
        ])
    }
}

// MARK: - Funcs
extension StopwatchTVCell {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(descriptionText: String, valueText: String) {
        descriptionLabel.text = descriptionText
        valueLabel.text = valueText
    }

    func updateColors(color: UIColor) {
        [descriptionLabel, valueLabel].forEach {
            $0.textColor = color
        }
    }
}
