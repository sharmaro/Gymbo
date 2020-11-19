//
//  StopwatchTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/15/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchTableViewCell: UITableViewCell {
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainBlack
        label.font = .medium
        label.textAlignment = .left
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainBlack
        label.font = .medium
        label.textAlignment = .justified
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

// MARK: - UITableViewCell Var/Funcs
extension StopwatchTableViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension StopwatchTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [descriptionLabel, valueLabel])
    }

    func setupColors() {
        backgroundColor = .mainWhite
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
extension StopwatchTableViewCell {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(descriptionText: String, valueText: String) {
        descriptionLabel.text = descriptionText
        valueLabel.text = valueText
    }

    func checkLapComparison(timeToCheck: Int, fastestTime: Int, slowestTime: Int) {
        if timeToCheck <= fastestTime {
            descriptionLabel.textColor = .systemGreen
            valueLabel.textColor = .systemGreen
        } else if timeToCheck >= slowestTime {
            descriptionLabel.textColor = .systemRed
            valueLabel.textColor = .systemRed
        } else {
            descriptionLabel.textColor = .mainBlack
            valueLabel.textColor = .mainBlack
        }
    }
}
