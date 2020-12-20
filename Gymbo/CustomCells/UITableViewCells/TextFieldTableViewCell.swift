//
//  TextFieldTableViewCell.swift
//
//
//  Created by Rohan Sharma on 5/26/20.
//

import UIKit

// MARK: - Properties
class TextFieldTableViewCell: UITableViewCell {
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
extension TextFieldTableViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension TextFieldTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [textField])
    }

    func setupViews() {
        selectionStyle = .none

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        textField.textColor = .dynamicBlack
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension TextFieldTableViewCell {
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
extension TextFieldTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        customTextFieldDelegate?.textFieldEditingDidEnd(textField: textField)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customTextFieldDelegate?.textFieldShouldReturn(textField) ?? true
    }
}
