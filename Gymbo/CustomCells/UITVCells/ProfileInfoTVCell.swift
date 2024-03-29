//
//  ProfileInfoTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/1/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileInfoTVCell: RoundedTVCell {
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()

    private let leftLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normal.semibold
        label.backgroundColor = .clear
        return label
    }()

    private let rightTextField: UITextField = {
        let textField = UITextField()
        textField.font = .normal
        textField.placeholder = "Not Set"
        textField.textAlignment = .right
        textField.returnKeyType = .done
        textField.backgroundColor = .clear
        textField.clearButtonMode = .whileEditing
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

// MARK: - Structs/Enums
private extension ProfileInfoTVCell {
}

// MARK: - UIView Var/Funcs
extension ProfileInfoTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ProfileInfoTVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [contentStackView])
        [leftLabel, rightTextField].forEach {
            contentStackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        rightTextField.delegate = self
    }

    func setupColors() {
        leftLabel.textColor = .primaryText
        rightTextField.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            contentStackView.centerY.constraint(
                equalTo: roundedView.centerY),
            contentStackView.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            contentStackView.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20)
        ])
    }
}

// MARK: - Funcs
extension ProfileInfoTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(leftText: String,
                   rightText: String,
                   keyboardType: UIKeyboardType,
                   row: Int) {
        leftLabel.text = leftText
        rightTextField.text = rightText
        rightTextField.keyboardType = keyboardType
        rightTextField.tag = row
    }
}

// MARK: - UITextFieldDelegate
extension ProfileInfoTVCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        customTextFieldDelegate?.textFieldShouldReturn(textField) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        customTextFieldDelegate?.textFieldEditingDidEnd(textField: textField)
    }
}
