//
//  TwoLabelsTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/19/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TwoLabelsTVCell: RoundedTVCell {
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium.bold
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normal.light
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
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
extension TwoLabelsTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension TwoLabelsTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [topLabel, bottomLabel])
    }

    func setupColors() {
        topLabel.textColor = .primaryText
        bottomLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            topLabel.top.constraint(
                equalTo: roundedView.top,
                constant: 10),
            topLabel.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            topLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            topLabel.bottom.constraint(equalTo: bottomLabel.top),

            bottomLabel.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            bottomLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            bottomLabel.bottom.constraint(
                equalTo: roundedView.bottom,
                constant: -10)
        ])
    }
}

// MARK: - Funcs
extension TwoLabelsTVCell {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(topText: String, bottomText: String) {
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
}
