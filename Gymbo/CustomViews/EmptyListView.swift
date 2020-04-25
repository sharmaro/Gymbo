//
//  EmptyListView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/25/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class EmptyListView: UIView {
    private var label = UILabel(frame: .zero)

    // MARK: - UIView Var/Funcs
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ViewAdding
extension EmptyListView: ViewAdding {
    func addViews() {
        add(subViews: [label])
    }

    func setupViews() {
        label.font = .large
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
    }

    func addConstraints() {
        label.autoPinEdges(to: self)
    }
}

// MARK: - Funcs
extension EmptyListView {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func set(message: String) {
        label.text = message
    }
}
