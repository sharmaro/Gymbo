//
//  SelectionTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionTVCell: RoundedTVCell {
    private let leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .primaryText
        return imageView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        return stackView
    }()

    private var stackViewLeadingConstraintToContentView = NSLayoutConstraint()
    private var stackViewLeadingConstraintToImageView = NSLayoutConstraint()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .primaryText
        label.font = .medium
        label.textAlignment = .left
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryText
        label.font = UIFont.medium.light
        label.textAlignment = .right
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
extension SelectionTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SelectionTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [leftImageView, stackView])
        [titleLabel, valueLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        showsRightImage = true
    }

    func setupColors() {
        [titleLabel, valueLabel].forEach { $0.textColor = $0.textColor }
    }

    func addConstraints() {
        stackViewLeadingConstraintToContentView = stackView.leading.constraint(
            equalTo: roundedView.leading,
            constant: 20)
        stackViewLeadingConstraintToImageView = stackView.leading.constraint(
            equalTo: leftImageView.trailing,
            constant: 10)

        NSLayoutConstraint.activate([
            leftImageView.centerY.constraint(equalTo: roundedView.centerY),
            leftImageView.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            leftImageView.width.constraint(equalToConstant: 25),
            leftImageView.height.constraint(equalTo: leftImageView.width),

            stackView.top.constraint(equalTo: roundedView.top),
            stackViewLeadingConstraintToImageView,
            stackView.trailing.constraint(
                equalTo: rightImageView.leading,
                constant: -20),
            stackView.bottom.constraint(equalTo: roundedView.bottom)
        ])
    }
}

// MARK: - Funcs
extension SelectionTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(leftImage: UIImage? = nil,
                   title: String,
                   value: String,
                   rightImage: UIImage?) {
        if leftImage == nil {
            stackViewLeadingConstraintToImageView.isActive = false
            stackViewLeadingConstraintToContentView.isActive = true
        } else {
            stackViewLeadingConstraintToContentView.isActive = false
            stackViewLeadingConstraintToImageView.isActive = true
            leftImageView.image = leftImage?.withRenderingMode(.alwaysTemplate)
        }

        titleLabel.text = title
        valueLabel.text = value
        rightImageView.image = rightImage?.withRenderingMode(.alwaysTemplate)
    }
}
