//
//  TwoLabelsTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/19/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TwoLabelsTVCell: UITableViewCell {
    private let topLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let bottomLabel: UILabel = {
        let label = UILabel()
        label.font = .normal
        label.minimumScaleFactor = 0.5
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
        contentView.add(subviews: [topLabel, bottomLabel])
    }

    func setupViews() {
        selectionStyle = .none
    }
    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        [topLabel, bottomLabel].forEach {
            $0.backgroundColor = .dynamicWhite
        }
        topLabel.textColor = .dynamicBlack
        bottomLabel.textColor = .dynamicDarkGray
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            topLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            topLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            topLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            topLabel.bottomAnchor.constraint(equalTo: bottomLabel.topAnchor),

            bottomLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension TwoLabelsTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(topText: String, bottomText: String) {
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
}
