//
//  StartedSessionFV.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/12/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StartedSessionFV: UIView {
    private let addExerciseButton: CustomButton = {
        let button = CustomButton()
        button.title = "+ Exercise"
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private let cancelButton: CustomButton = {
        let button = CustomButton()
        button.title = "Cancel"
        button.set(backgroundColor: .systemRed)
        button.addCorner(style: .small)
        return button
    }()

    weak var startedSessionButtonDelegate: StartedSessionButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension StartedSessionFV {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension StartedSessionFV: ViewAdding {
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
            addExerciseButton.top.constraint(
                equalTo: top,
                constant: 15),
            addExerciseButton.leading.constraint(
                equalTo: leading,
                constant: 20),
            addExerciseButton.trailing.constraint(
                equalTo: trailing,
                constant: -20),
            addExerciseButton.bottom.constraint(
                equalTo: cancelButton.top,
                constant: -15),
            addExerciseButton.height.constraint(equalTo: cancelButton.height),

            cancelButton.leading.constraint(
                equalTo: leading,
                constant: 20),
            cancelButton.trailing.constraint(
                equalTo: trailing,
                constant: -20),
            cancelButton.bottom.constraint(
                equalTo: bottom,
                constant: -15)
        ])
    }
}

// MARK: - Funcs
extension StartedSessionFV {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        startedSessionButtonDelegate?.addExercise()
    }

    @objc private func cancelButtonTapped(_ sender: Any) {
        startedSessionButtonDelegate?.cancelSession()
    }
}
