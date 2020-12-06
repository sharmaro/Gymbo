//
//  StartSessionFooterView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/12/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StartSessionFooterView: UIView {
    private let addExerciseButton: CustomButton = {
        let button = CustomButton()
        button.title = "+ Exercise"
        button.add(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private let cancelButton: CustomButton = {
        let button = CustomButton()
        button.title = "Cancel"
        button.add(backgroundColor: .systemRed)
        button.addCorner(style: .small)
        return button
    }()

    weak var startSessionButtonDelegate: StartSessionButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension StartSessionFooterView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension StartSessionFooterView: ViewAdding {
    func addViews() {
        add(subviews: [addExerciseButton, cancelButton])
    }

    func setupViews() {
        addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        backgroundColor = .clear
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: topAnchor),
            addExerciseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addExerciseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addExerciseButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -15),
            addExerciseButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),

            cancelButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - Funcs
extension StartSessionFooterView {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.addExercise()
    }

    @objc private func cancelButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.cancelSession()
    }
}
