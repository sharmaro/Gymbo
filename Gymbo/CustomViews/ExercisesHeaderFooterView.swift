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
    private var label = UILabel()

    // MARK: - UIView Var/Funcs
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ViewAdding
extension ExercisesHeaderFooterView: ViewAdding {
    func addViews() {
        add(subviews: [label])
    }

    func setupViews() {
        label.font = .medium
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
        setupViews()
        addConstraints()
    }

    func configure(title: String) {
        label.text = title
    }
}
