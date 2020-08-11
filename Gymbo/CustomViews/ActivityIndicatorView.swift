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
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = UIFont.normal.bold
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private var text: String?

    // MARK: - UIView Var/Funcs
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
        super.init(coder: coder)

        setup()
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
        backgroundColor = .clear

        label.text = text

        if text == nil {
            activityIndicatorView.style = .whiteLarge
            contentBlurEffectView.effect = nil
        }
    }

    func addConstraints() {
        containerBlurEffectView.autoPinEdges(to: self)

        NSLayoutConstraint.activate([
            contentBlurEffectView.centerXAnchor.constraint(equalTo: containerBlurEffectView.centerXAnchor),
            contentBlurEffectView.centerYAnchor.constraint(equalTo: containerBlurEffectView.centerYAnchor),
            contentBlurEffectView.widthAnchor.constraint(equalToConstant: 200),
            contentBlurEffectView.heightAnchor.constraint(equalToConstant: 60),

            stackView.leadingAnchor.constraint(equalTo: contentBlurEffectView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentBlurEffectView.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: contentBlurEffectView.centerYAnchor)
        ])
    }
}

// MARK: - Funcs
extension ActivityIndicatorView {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }
}
