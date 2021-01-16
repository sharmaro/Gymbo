//
//  ImageAndLabelView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ImageAndLabelView: UIView {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    var label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension ImageAndLabelView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ImageAndLabelView: ViewAdding {
    func addViews() {
        add(subviews: [imageView, label])
    }

    func setupColors() {
        backgroundColor = .clear
        label.textColor = label.textColor
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            imageView.top.constraint(equalTo: top),
            imageView.leading.constraint(equalTo: leading),
            imageView.trailing.constraint(
                equalTo: label.leading,
                constant: -5),
            imageView.bottom.constraint(equalTo: bottom),
            imageView.width.constraint(equalTo: imageView.height),

            label.top.constraint(equalTo: top),
            label.trailing.constraint(equalTo: trailing),
            label.bottom.constraint(equalTo: bottom)
        ])
    }
}

// MARK: - Funcs
extension ImageAndLabelView {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }
}
