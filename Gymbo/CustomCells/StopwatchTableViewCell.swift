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
    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 20)
        label.textAlignment = .justified
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupLabels()
    }
}

// MARK: - Funcs
extension StopwatchTableViewCell {
    private func setupLabels() {
        addSubviews(views: [descriptionLabel, valueLabel])

        NSLayoutConstraint.activate([
            descriptionLabel.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            descriptionLabel.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            descriptionLabel.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            valueLabel.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            valueLabel.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            valueLabel.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            valueLabel.widthAnchor.constraint(equalToConstant: 90)
        ])
        layoutIfNeeded()
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
