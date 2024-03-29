//
//  LabelTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class LabelTVCell: RoundedTVCell {
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
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension LabelTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension LabelTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [detailLabel])
    }

    func setupColors() {
        detailLabel.textColor = .primaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            detailLabel.top.constraint(
                equalTo: roundedView.top,
                constant: 10),
            detailLabel.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            detailLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            detailLabel.bottom.constraint(
                equalTo: roundedView.bottom,
                constant: -10)
        ])
    }
}

// MARK: - Funcs
extension LabelTVCell {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(text: String, font: UIFont = .normal) {
        detailLabel.text = text
        detailLabel.font = font
    }
}
