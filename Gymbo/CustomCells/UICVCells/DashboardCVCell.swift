//
//  DashboardCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/31/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DashboardCVCell: UICollectionViewCell {
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .large
        return label
    }()

    private var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .normal
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
        contentView.add(subviews: [titleLabel, contentLabel])
    }

    func setupViews() {
        contentView.layer.addCorner(style: .small)
        contentView.addBorder(1, color: .dynamicDarkGray)
        contentView.addShadow(direction: .downRight)
    }

    func setupColors() {
        contentView.layer.borderColor = UIColor.dynamicDarkGray.cgColor
        contentView.layer.shadowColor = UIColor.dynamicDarkGray.cgColor
        contentView.backgroundColor = .dynamicWhite
        titleLabel.textColor = .dynamicBlack
        contentLabel.textColor = .dynamicDarkGray
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -10),

            contentLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            contentLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            contentLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Funcs
extension DashboardCVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(title: String, content: String) {
        titleLabel.text = title
        contentLabel.text = content
    }
}