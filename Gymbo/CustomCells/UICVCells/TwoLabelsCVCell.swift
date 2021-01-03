//
//  TwoLabelsCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TwoLabelsCVCell: UICollectionViewCell {
    private var labelsVStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalCentering
        stackView.spacing = 5
        return stackView
    }()

    private let topLabel = UILabel()
    private let bottomLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension TwoLabelsCVCell {
}

// MARK: - UIView Var/Funcs
extension TwoLabelsCVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension TwoLabelsCVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [labelsVStackView])
        [topLabel, bottomLabel].forEach {
            labelsVStackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        topLabel.font = UIFont.medium.semibold
        bottomLabel.font = UIFont.normal.light
        [topLabel, bottomLabel].forEach {
            $0.lineBreakMode = .byTruncatingTail
        }

        contentView.layer.addCorner(style: .small)
        contentView.addBorder(1, color: .dynamicDarkGray)
        contentView.addShadow(direction: .downRight)
    }

    func setupColors() {
        contentView.layer.borderColor = UIColor.dynamicDarkGray.cgColor
        contentView.layer.shadowColor = UIColor.dynamicDarkGray.cgColor
        contentView.backgroundColor = .dynamicWhite
        [topLabel, bottomLabel].forEach { $0.textColor = .dynamicBlack }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            labelsVStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                      constant: 15),
            labelsVStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsVStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -15)
        ])
    }
}

// MARK: - Funcs
extension TwoLabelsCVCell {
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
