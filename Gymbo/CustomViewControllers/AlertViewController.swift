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
    private lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.roundCorner(radius: 10)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24)
        label.backgroundColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var contentLabel: UILabel! = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 17)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var leftButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.title = "Cancel"
        button.add(backgroundColor: .systemRed)
        button.titleFontSize = 15
        button.addCorner()
        button.addTarget(self, action: #selector(leftButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var rightButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.title = "Confirm"
        button.add(backgroundColor: .systemGreen)
        button.titleFontSize = 15
        button.addCorner()
        button.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var alertTitle: String?
    private var content: String?
    private var usesBothButtons: Bool?
    private var leftButtonTitle: String?
    private var rightButtonTitle: String?
    private var leftButtonAction: (() -> Void)?
    private var rightButtonAction: (() -> Void)?
}

// MARK: - UIViewController Var/Funcs
extension AlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        addMainViews()
        setupConstraints()
        setupAlertView()
    }
}

// MARK: - Funcs
extension AlertViewController {
    private func addMainViews() {
        view.addSubviews(views: [containerView])
        containerView.addSubviews(views: [titleLabel, contentLabel, buttonsStackView])
        buttonsStackView.addArrangedSubview(leftButton)
        buttonsStackView.addArrangedSubview(rightButton)
    }

    private func setupConstraints() {
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

    private func setupAlertView() {
        titleLabel.text = alertTitle
        contentLabel.text = content

        if usesBothButtons ?? true {
            leftButton.title = leftButtonTitle ?? ""
            rightButton.title = rightButtonTitle ?? ""
        } else {
            rightButton.title = rightButtonTitle ?? ""
        }
    }

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
