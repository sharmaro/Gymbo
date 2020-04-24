//
//  StartSessionFooterView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/12/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol StartSessionButtonDelegate: class {
    func addExercise()
    func cancelSession()
}

// MARK: - Properties
class StartSessionFooterView: UIView {
    private var addExerciseButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private var cancelButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    weak var startSessionButtonDelegate: StartSessionButtonDelegate?

    // MARK: - UIView Var/Funcs
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - Funcs
extension StartSessionFooterView {
    private func setup() {
        addViews()
        setupViews()
        setupConstraints()
    }

    private func addViews() {
        addSubviews(views: [addExerciseButton, cancelButton])
    }

    private func setupViews() {
        addExerciseButton.title = "+ Exercise"
        addExerciseButton.titleFontSize = 15
        addExerciseButton.add(backgroundColor: .systemBlue)
        addExerciseButton.addCorner()
        addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)

        cancelButton.title = "Cancel"
        cancelButton.titleFontSize = 15
        cancelButton.add(backgroundColor: .systemRed)
        cancelButton.addCorner()
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            addExerciseButton.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            addExerciseButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addExerciseButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addExerciseButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -15),
            addExerciseButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            cancelButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -15)
        ])
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.addExercise()
    }

    @objc private func cancelButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.cancelSession()
    }
}
