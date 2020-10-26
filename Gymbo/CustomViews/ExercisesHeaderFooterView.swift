//
//  ExercisesHeaderFooterView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisesHeaderFooterView: UITableViewHeaderFooterView {
    private let label: UILabel = {
        let label = UILabel()
        label.font = .medium
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - UIView Var/Funcs
extension ExercisesHeaderFooterView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ExercisesHeaderFooterView: ViewAdding {
    func addViews() {
        add(subviews: [label])
    }

    func setupColors() {
        let customBackgroundView = UIView()
        customBackgroundView.backgroundColor = .mainLightGray
        backgroundView = customBackgroundView
        label.textColor = .mainBlack
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Funcs
extension ExercisesHeaderFooterView {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(title: String) {
        label.text = title
    }
}
