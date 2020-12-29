//
//  StopwatchTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/15/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchTVCell: UITableViewCell {
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dynamicBlack
        label.font = .medium
        label.textAlignment = .left
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dynamicBlack
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
        contentView.add(subviews: [descriptionLabel, valueLabel])
    }

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        [descriptionLabel, valueLabel].forEach { $0.textColor = $0.textColor }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            valueLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 90)
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
