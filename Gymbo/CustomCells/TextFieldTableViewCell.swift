//
//  TextFieldTableViewCell.swift
//
//
//  Created by Rohan Sharma on 5/26/20.
//

import UIKit

protocol TextFieldTableViewCellDelegate: class {
    func textFieldEditingChanged(textField: UITextField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

extension TextFieldTableViewCellDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

// MARK: - Properties
class TextFieldTableViewCell: UITableViewCell {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.font = .normal
        textField.autocapitalizationType = .words
        textField.borderStyle = .none
        return textField
    }()

    weak var textFieldTableViewCellDelegate: TextFieldTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - ViewAdding
extension TextFieldTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [textField])
    }

    func setupViews() {
        selectionStyle = .none

        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension TextFieldTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    @objc private func textFieldEditingChanged(textField: UITextField) {
        textFieldTableViewCellDelegate?.textFieldEditingChanged(textField: textField)
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textFieldTableViewCellDelegate?.textFieldShouldReturn(textField) ?? true
    }
}
