//
//  TextFieldTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TextFieldTVCell: RoundedTVCell {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .normal
        textField.autocapitalizationType = .words
        textField.borderStyle = .none
        return textField
    }()

    weak var customTextFieldDelegate: CustomTextFieldDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension TextFieldTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension TextFieldTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [textField])
    }

    func setupViews() {
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }

    func setupColors() {
        textField.textColor = .primaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            textField.top.constraint(
                equalTo: roundedView.top,
                constant: 10),
            textField.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            textField.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            textField.bottom.constraint(
                equalTo: roundedView.bottom,
                constant: -10)
        ])
    }
}

// MARK: - Funcs
extension TextFieldTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    @objc private func textFieldEditingChanged(textField: UITextField) {
        customTextFieldDelegate?.textFieldEditingChanged(textField: textField)
    }

    func configure(text: String, placeHolder: String, returnKeyType: UIReturnKeyType = .done) {
        if !text.isEmpty {
            textField.text = text
        }
        textField.placeholder = placeHolder
        textField.returnKeyType = returnKeyType
    }
}

// MARK: - UITextFieldDelegate
extension TextFieldTVCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        customTextFieldDelegate?.textFieldEditingDidEnd(textField: textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customTextFieldDelegate?.textFieldShouldReturn(textField) ?? true
    }
}
