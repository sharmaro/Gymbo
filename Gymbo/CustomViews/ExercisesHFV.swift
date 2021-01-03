//
//  ExercisesHFV.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisesHFV: UITableViewHeaderFooterView {
    private let topDivider = UIView()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .medium
        return label
    }()

    private let bottomDivider = UIView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension ExercisesHFV {
    struct Constants {
        static var dividerHeight = CGFloat(0.2)
    }
}

// MARK: - UIView Var/Funcs
extension ExercisesHFV {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ExercisesHFV: ViewAdding {
    func addViews() {
        add(subviews: [topDivider, label, bottomDivider])
    }

    func setupColors() {
        let customBackgroundView = UIView()
        customBackgroundView.backgroundColor = .dynamicLightGray
        backgroundView = customBackgroundView

        [topDivider, bottomDivider].forEach {
            $0.backgroundColor = .dynamicDarkGray
        }
        label.textColor = .dynamicBlack
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            topDivider.topAnchor.constraint(equalTo: topAnchor),
            topDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            topDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            topDivider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),

            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),

            bottomDivider.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomDivider.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomDivider.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomDivider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight)
        ])
    }
}

// MARK: - Funcs
extension ExercisesHFV {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(title: String) {
        label.text = title
    }
}
