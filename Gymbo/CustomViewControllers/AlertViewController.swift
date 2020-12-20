//
//  AlertViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AlertViewController: UIViewController {
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
        button.add(backgroundColor: .systemRed)
        button.addCorner(style: .small)
        return button
    }()

    private let rightButton: CustomButton = {
        let button = CustomButton()
        button.title = "Confirm"
        button.titleLabel?.font = .normal
        button.add(backgroundColor: .systemGreen)
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
extension AlertViewController {
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
extension AlertViewController: ViewAdding {
    func addViews() {
        view.add(subviews: [containerView])
        containerView.add(subviews: [titleLabel, contentLabel, buttonsStackView])
        if alertData.usesBothButtons {
            buttonsStackView.addArrangedSubview(leftButton)
        }
        buttonsStackView.addArrangedSubview(rightButton)
    }

    func setupViews() {
        view.backgroundColor = .dimmedBackgroundBlack

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
        containerView.backgroundColor = .dynamicLightGray
        titleLabel.textColor = .white
        contentLabel.textColor = .dynamicBlack
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            containerView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 45),

            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -10),

            buttonsStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor, constant: -10),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 45)
        ])
        buttonsStackView.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension AlertViewController {
    @objc private func leftButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        alertData.leftButtonAction?()
    }

    @objc private func rightButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        alertData.rightButtonAction?()
    }
}
