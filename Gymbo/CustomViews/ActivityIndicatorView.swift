//
//  ActivityIndicatorView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

class ActivityIndicatorView: UIView {
// MARK: - Properties
    private let containerBlurEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return visualEffectView
    }()

    private let contentBlurEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        visualEffectView.addCorner(style: .small)
        return visualEffectView
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 20
        return stackView
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.normal.bold
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private var text: String?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    init(withText text: String? = nil) {
        super.init(frame: .zero)

        self.text = text
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension ActivityIndicatorView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ActivityIndicatorView: ViewAdding {
    func addViews() {
        add(subviews: [containerBlurEffectView])
        containerBlurEffectView.contentView.add(subviews: [contentBlurEffectView])
        let contentSubviews = (text == nil) ? [activityIndicatorView] : [activityIndicatorView, label]
        for view in contentSubviews {
            stackView.addArrangedSubview(view)
        }
        contentBlurEffectView.contentView.add(subviews: [stackView])
    }

    func setupViews() {
        label.text = text

        if text == nil {
            activityIndicatorView.style = .large
            contentBlurEffectView.effect = nil
        }
    }

    func setupColors() {
        backgroundColor = .clear
        label.textColor = .darkGray
    }

    func addConstraints() {
        containerBlurEffectView.autoPinEdges(to: self)

        NSLayoutConstraint.activate([
            contentBlurEffectView.centerX.constraint(equalTo: containerBlurEffectView.centerX),
            contentBlurEffectView.centerY.constraint(equalTo: containerBlurEffectView.centerY),
            contentBlurEffectView.width.constraint(equalToConstant: 200),
            contentBlurEffectView.height.constraint(equalToConstant: 60),

            stackView.leading.constraint(
                equalTo: contentBlurEffectView.leading,
                constant: 20),
            stackView.trailing.constraint(
                equalTo: contentBlurEffectView.trailing,
                constant: -20),
            stackView.centerY.constraint(equalTo: contentBlurEffectView.centerY)
        ])
    }
}

// MARK: - Funcs
extension ActivityIndicatorView {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }
}
