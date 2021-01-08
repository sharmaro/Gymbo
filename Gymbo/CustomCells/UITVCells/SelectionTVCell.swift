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
        stackViewLeadingConstraintToContentView = stackView.leadingAnchor
            .constraint(equalTo: roundedView.leadingAnchor,
                        constant: 20)
        stackViewLeadingConstraintToImageView = stackView.leadingAnchor
            .constraint(equalTo: leftImageView.trailingAnchor,
                        constant: 10)

        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor,
                                                   constant: 20),
            leftImageView.widthAnchor.constraint(equalToConstant: 25),
            leftImageView.heightAnchor.constraint(equalTo: leftImageView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: roundedView.topAnchor),
            stackViewLeadingConstraintToImageView,
            stackView.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor,
                                                constant: -20),
            stackView.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor)
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
