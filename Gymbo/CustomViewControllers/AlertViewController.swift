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
    private var containerView = UIView(frame: .zero)
    private var titleLabel = UILabel(frame: .zero)
    private var contentLabel = UILabel(frame: .zero)

    private var buttonsStackView = UIStackView(frame: .zero)
    private var leftButton = CustomButton(frame: .zero)
    private var rightButton = CustomButton(frame: .zero)

    private var alertTitle: String?
    private var content: String?
    private var usesBothButtons = true
    private var leftButtonTitle: String?
    private var rightButtonTitle: String?
    private var leftButtonAction: (() -> Void)?
    private var rightButtonAction: (() -> Void)?
}

// MARK: - ViewAdding
extension AlertViewController: ViewAdding {
    func addViews() {
        view.add(subviews: [containerView])
        containerView.add(subviews: [titleLabel, contentLabel, buttonsStackView])
        if usesBothButtons {
            buttonsStackView.addArrangedSubview(leftButton)
        }
        buttonsStackView.addArrangedSubview(rightButton)
    }

    func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        containerView.backgroundColor = .white
        containerView.addCorner(style: .small)

        titleLabel.text = alertTitle
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .large
        titleLabel.backgroundColor = .systemBlue

        contentLabel.text = content
        contentLabel.font = .normal
        contentLabel.numberOfLines = 0

        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 15

        if usesBothButtons {
            leftButton.title = "Cancel"
            leftButton.titleLabel?.font = .normal
            leftButton.add(backgroundColor: .systemRed)
            leftButton.addCorner(style: .small)
            leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        }

        rightButton.title = "Confirm"
        rightButton.titleLabel?.font = .normal
        rightButton.add(backgroundColor: .systemGreen)
        rightButton.addCorner(style: .small)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)

        leftButton.title = usesBothButtons ? (leftButtonTitle ?? "") : ""
        rightButton.title = rightButtonTitle ?? ""
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentLabel.topAnchor, constant: -10),
            titleLabel.heightAnchor.constraint(equalToConstant: 45)
        ])

        NSLayoutConstraint.activate([
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            contentLabel.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -10)
        ])

        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 45)
        ])
        buttonsStackView.layoutIfNeeded()
    }
}

// MARK: - UIViewController Var/Funcs
extension AlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        setupViews()
        addConstraints()
    }
}

// MARK: - Funcs
extension AlertViewController {
    func setupAlert(title: String = "Alert", content: String, usesBothButtons: Bool = true, leftButtonTitle: String = "Cancel", rightButtonTitle: String = "Confirm", leftButtonAction: (() -> Void)? = nil, rightButtonAction: (() -> Void)? = nil) {
        alertTitle = title
        self.content = content
        self.usesBothButtons = usesBothButtons
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }

    @objc private func leftButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        leftButtonAction?()
    }

    @objc private func rightButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        rightButtonAction?()
    }
}
