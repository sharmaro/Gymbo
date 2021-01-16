//
//  AlertVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AlertVC: UIViewController {
    private let blurredView = VisualEffectView()

    private let containerView: UIView = {
        let view = UIView()
        view.addCorner(style: .small)
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .large
        label.backgroundColor = .systemBlue
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .normal
        label.numberOfLines = 0
        return label
    }()

    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        return stackView
    }()

    // Not always created
    private lazy var leftButton: CustomButton = {
        let button = CustomButton()
        button.title = "Cancel"
        button.titleLabel?.font = .normal
        button.set(backgroundColor: .systemRed)
        button.addCorner(style: .small)
        return button
    }()

    private let rightButton: CustomButton = {
        let button = CustomButton()
        button.title = "Confirm"
        button.titleLabel?.font = .normal
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private var alertData: AlertData

    init(alertData: AlertData) {
        self.alertData = alertData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIViewController Var/Funcs
extension AlertVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension AlertVC: ViewAdding {
    func addViews() {
        view.add(subviews: [blurredView, containerView])
        containerView.add(subviews: [titleLabel, contentLabel, buttonsStackView])
        if alertData.usesBothButtons {
            buttonsStackView.addArrangedSubview(leftButton)
        }
        buttonsStackView.addArrangedSubview(rightButton)
    }

    func setupViews() {
        view.backgroundColor = .clear

        titleLabel.text = alertData.title
        contentLabel.text = alertData.content

        if alertData.usesBothButtons {
            leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        }
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)

        leftButton.title = alertData.usesBothButtons ? (alertData.leftButtonTitle ?? "") : ""
        rightButton.title = alertData.rightButtonTitle ?? ""
    }

    func setupColors() {
        containerView.backgroundColor = .primaryBackground
        titleLabel.textColor = .white
        contentLabel.textColor = .primaryText
    }

    func addConstraints() {
        blurredView.autoPinEdges(to: view)
        NSLayoutConstraint.activate([
            containerView.centerY.constraint(equalTo: view.centerY),
            containerView.safeLeading.constraint(
                equalTo: view.safeLeading,
                constant: 20),
            containerView.safeTrailing.constraint(
                equalTo: view.safeTrailing,
                constant: -20),

            titleLabel.top.constraint(equalTo: containerView.top),
            titleLabel.leading.constraint(equalTo: containerView.leading),
            titleLabel.trailing.constraint(equalTo: containerView.trailing),
            titleLabel.bottom.constraint(
                equalTo: contentLabel.top,
                constant: -10),
            titleLabel.height.constraint(equalToConstant: 45),

            contentLabel.leading.constraint(
                equalTo: containerView.leading,
                constant: 20),
            contentLabel.trailing.constraint(
                equalTo: containerView.trailing,
                constant: -20),
            contentLabel.bottom.constraint(
                equalTo: buttonsStackView.top,
                constant: -10),

            buttonsStackView.leading.constraint(equalTo: containerView.leading,
                                                constant: 20),
            buttonsStackView.trailing.constraint(equalTo: containerView.trailing,
                                                 constant: -20),
            buttonsStackView.bottom.constraint(equalTo: containerView.bottom,
                                               constant: -10),
            buttonsStackView.height.constraint(equalToConstant: 45)
        ])
        buttonsStackView.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension AlertVC {
    @objc private func leftButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
        alertData.leftButtonAction?()
    }

    @objc private func rightButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
        alertData.rightButtonAction?()
    }
}
