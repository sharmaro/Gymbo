//
//  SelectionTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionTableViewCell: UITableViewCell {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        return stackView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainBlack
        label.font = .medium
        label.textAlignment = .left
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mainDarkGray
        label.font = UIFont.medium.light
        label.textAlignment = .right
        return label
    }()

    private var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .mainBlack
        return imageView
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
extension SelectionTableViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SelectionTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [stackView, rightImageView])
        [titleLabel, valueLabel].forEach {
            stackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .mainLightGray
    }

    func setupColors() {
        backgroundColor = .mainWhite
        contentView.backgroundColor = .clear
        [titleLabel, valueLabel].forEach { $0.textColor = $0.textColor }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: rightImageView.leadingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            rightImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rightImageView.widthAnchor.constraint(equalToConstant: 15),
            rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor)
        ])
    }
}

// MARK: - Funcs
extension SelectionTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(title: String, value: String, image: UIImage?) {
        titleLabel.text = title
        valueLabel.text = value
        rightImageView.image = image?.withRenderingMode(.alwaysTemplate)
    }
}
