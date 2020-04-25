//
//  EmptyCollectionViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/25/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class EmptyCollectionViewCell: UICollectionViewCell {
    private var emptyListView = EmptyListView(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ReuseIdentifying
extension EmptyCollectionViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension EmptyCollectionViewCell: ViewAdding {
    func addViews() {
        add(subViews: [emptyListView])
    }

    func addConstraints() {
        emptyListView.autoPinEdges(to: self)
    }
}

// MARK: - Funcs
extension EmptyCollectionViewCell {
    private func setup() {
        addViews()
        addConstraints()
    }

    func set(message: String) {
        emptyListView.set(message: message)
    }
}
