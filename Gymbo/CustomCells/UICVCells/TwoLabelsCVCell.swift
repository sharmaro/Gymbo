//
//  TwoLabelsCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TwoLabelsCVCell: RoundedCVCell {
    private var indexLabel = UILabel()

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
        roundedView.add(subviews: [indexLabel, labelsVStackView])
        [topLabel, bottomLabel].forEach {
            labelsVStackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        indexLabel.font = UIFont.medium.semibold
        topLabel.font = UIFont.medium.semibold
        bottomLabel.font = UIFont.normal.light
        [topLabel, bottomLabel].forEach {
            $0.lineBreakMode = .byTruncatingTail
        }
    }

    func setupColors() {
        [indexLabel, topLabel].forEach { $0.textColor = .primaryText }
        bottomLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            indexLabel.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            indexLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor,
                                                constant: 20),
            indexLabel.trailingAnchor.constraint(equalTo: labelsVStackView.leadingAnchor,
                                                constant: -15),

            labelsVStackView.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            labelsVStackView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor,
                                                      constant: -20)
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

    func configure(index: Int, topText: String, bottomText: String) {
        indexLabel.text = "\(index)"
        topLabel.text = topText
        bottomLabel.text = bottomText
    }
}
