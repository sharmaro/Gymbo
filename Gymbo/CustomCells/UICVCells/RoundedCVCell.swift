//
//  RoundedCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/7/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class RoundedCVCell: UICollectionViewCell {
    let roundedView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension RoundedCVCell {
    override var isHighlighted: Bool {
        didSet {
            roundedView.backgroundColor = isHighlighted ?
                .selectedBackground : .secondaryBackground
            Transform.caseFromBool(bool: isHighlighted).transform(view: self)
        }
    }

    override var isSelected: Bool {
        didSet {
            roundedView.backgroundColor = isSelected ?
                .selectedBackground : .secondaryBackground
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension RoundedCVCell {
    private func addViews() {
        contentView.add(subviews: [roundedView])
    }

    private func setupViews() {
        roundedView.addCorner(style: .small)
    }

    private func setupColors() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        roundedView.backgroundColor = .secondaryBackground
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            roundedView.top.constraint(equalTo: contentView.top),
            roundedView.leading.constraint(
                equalTo: contentView.leading,
                constant: 20),
            roundedView.trailing.constraint(
                equalTo: contentView.trailing,
                constant: -20),
            roundedView.bottom.constraint(equalTo: contentView.bottom)
        ])
    }
}

// MARK: - Funcs
extension RoundedCVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }
}
