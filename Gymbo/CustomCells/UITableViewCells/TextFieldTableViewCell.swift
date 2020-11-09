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

// MARK: - UITableViewCell Var/Funcs
extension TextFieldTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()

        textField.text?.removeAll()
    }

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
        backgroundColor = .mainWhite
        contentView.backgroundColor = .clear
        textField.textColor = .mainBlack
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
