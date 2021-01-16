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
        customBackgroundView.backgroundColor = .primaryBackground
        backgroundView = customBackgroundView

        [topDivider, bottomDivider].forEach {
            $0.backgroundColor = .secondaryBackground
        }
        label.textColor = .primaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            topDivider.top.constraint(equalTo: top),
            topDivider.leading.constraint(equalTo: leading),
            topDivider.trailing.constraint(equalTo: trailing),
            topDivider.height.constraint(equalToConstant: Constants.dividerHeight),

            label.top.constraint(equalTo: top),
            label.leading.constraint(
                equalTo: leading,
                constant: 20),
            label.trailing.constraint(equalTo: trailing),
            label.bottom.constraint(equalTo: bottom),

            bottomDivider.leading.constraint(equalTo: leading),
            bottomDivider.trailing.constraint(equalTo: trailing),
            bottomDivider.bottom.constraint(equalTo: bottom),
            bottomDivider.height.constraint(equalToConstant: Constants.dividerHeight)
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
