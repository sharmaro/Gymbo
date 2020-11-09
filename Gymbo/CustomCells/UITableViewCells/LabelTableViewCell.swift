//
//  LabelTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class LabelTableViewCell: UITableViewCell {
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
        super.init(coder: coder)

        setup()
    }
}

// MARK: - UITableViewCell Var/Funcs
extension LabelTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()

        detailLabel.text?.removeAll()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension LabelTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [detailLabel])
    }

    func setupViews() {
        selectionStyle = .none
    }

    func setupColors() {
        backgroundColor = .mainWhite
        contentView.backgroundColor = .clear
        detailLabel.textColor = .mainBlack
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension LabelTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(text: String, font: UIFont = .normal) {
        detailLabel.text = text
        detailLabel.font = font
    }
}
