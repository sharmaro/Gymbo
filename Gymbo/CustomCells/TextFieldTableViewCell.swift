//
//  TextFieldTableViewCell.swift
//
//
//  Created by Rohan Sharma on 5/26/20.
//

import UIKit

protocol TextFieldTableViewCellDelegate: class {
    func textFieldEditingChanged(textField: UITextField)
}

// MARK: - Properties
class TextFieldTableViewCell: UITableViewCell {
    private var textField = UITextField()

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

// MARK: - ReuseIdentifying
extension TextFieldTableViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension TextFieldTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [textField])
    }

    func setupViews() {
        selectionStyle = .none

        textField.font = .normal
        textField.autocapitalizationType = .words
        textField.returnKeyType = .done
        textField.borderStyle = .none
        textField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
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

    func configure(text: String, placeHolder: String) {
        if !text.isEmpty {
            textField.text = text
        }
        textField.placeholder = placeHolder
    }
}
