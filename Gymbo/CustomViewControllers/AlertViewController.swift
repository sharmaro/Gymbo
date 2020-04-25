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
    private lazy var containerView = UIView(frame: .zero)
    private lazy var titleLabel = UILabel(frame: .zero)
    private lazy var contentLabel = UILabel(frame: .zero)

    private lazy var buttonsStackView = UIStackView(frame: .zero)
    private lazy var leftButton = CustomButton(frame: .zero)
    private lazy var rightButton = CustomButton(frame: .zero)

    private var alertTitle: String?
    private var content: String?
    private var usesBothButtons: Bool?
    private var leftButtonTitle: String?
    private var rightButtonTitle: String?
    private var leftButtonAction: (() -> Void)?
    private var rightButtonAction: (() -> Void)?
}

// MARK: - ViewAdding
extension AlertViewController: ViewAdding {
    func addViews() {
        view.add(subViews: [containerView])
        containerView.add(subViews: [titleLabel, contentLabel, buttonsStackView])
        buttonsStackView.addArrangedSubview(leftButton)
        buttonsStackView.addArrangedSubview(rightButton)
    }

    func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        containerView.backgroundColor = .white
        containerView.addCorner(style: .small)

        titleLabel.text = alertTitle
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.font = .xLarge
        titleLabel.backgroundColor = .systemBlue

        contentLabel.text = content
        contentLabel.font = .medium
        contentLabel.numberOfLines = 0

        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 15

        leftButton.title = "Cancel"
        leftButton.add(backgroundColor: .systemRed)
        leftButton.titleLabel?.font = .small
        leftButton.addCorner(style: .small)
        leftButton.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)

        rightButton.title = "Confirm"
        rightButton.add(backgroundColor: .systemGreen)
        rightButton.titleLabel?.font = .small
        rightButton.addCorner(style: .small)
        rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)

        if usesBothButtons ?? true {
            leftButton.title = leftButtonTitle ?? ""
            rightButton.title = rightButtonTitle ?? ""
        } else {
            rightButton.title = rightButtonTitle ?? ""
        }
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
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction

        guard isViewLoaded, !usesBothButtons else {
            return
        }
        leftButton.removeFromSuperview()
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
