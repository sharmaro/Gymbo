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
    private lazy var descriptionLabel = UILabel(frame: .zero)
    private lazy var valueLabel = UILabel(frame: .zero)

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
extension StopwatchTableViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension StopwatchTableViewCell: ViewAdding {
    func addViews() {
        add(subViews: [descriptionLabel, valueLabel])
    }

    func setupViews() {
        descriptionLabel.font = .large
        descriptionLabel.textAlignment = .left

        valueLabel.font = .large
        valueLabel.textAlignment = .justified
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            valueLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 90)
        ])
        layoutIfNeeded()
    }
}

// MARK: - Funcs
extension StopwatchTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(descriptionText: String, valueText: String) {
        descriptionLabel.text = descriptionText
        valueLabel.text = valueText

        descriptionLabel.textColor = .black
        valueLabel.textColor = .black
    }

    func checkLapComparison(timeToCheck: Int, fastestTime: Int, slowestTime: Int) {
        if timeToCheck <= fastestTime {
            descriptionLabel.textColor = .systemGreen
            valueLabel.textColor = .systemGreen
        } else if timeToCheck >= slowestTime {
            descriptionLabel.textColor = .systemRed
            valueLabel.textColor = .systemRed
        } else {
            descriptionLabel.textColor = .black
            valueLabel.textColor = .black
        }
    }
}
