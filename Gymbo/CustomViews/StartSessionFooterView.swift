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
    private var addExerciseButton = CustomButton(frame: .zero)
    private var cancelButton = CustomButton(frame: .zero)

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

// MARK: - ViewAdding
extension StartSessionFooterView: ViewAdding {
    func addViews() {
        add(subViews: [addExerciseButton, cancelButton])
    }

    func setupViews() {
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

    func addConstraints() {
        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: topAnchor),
            addExerciseButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addExerciseButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addExerciseButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -15),
            addExerciseButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])

        NSLayoutConstraint.activate([
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
        addConstraints()
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.addExercise()
    }

    @objc private func cancelButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.cancelSession()
    }
}
