//
//  TwoLabelsTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/19/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TwoLabelsTableViewCell: UITableViewCell {
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
        label.textColor = .systemGray
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
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

// MARK: - ViewAdding
extension TwoLabelsTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [topLabel, bottomLabel])
    }

    func setupViews() {
        selectionStyle = .none
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
extension TwoLabelsTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(topText: String, bottomText: String) {
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
}
