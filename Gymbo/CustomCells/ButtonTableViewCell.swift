//
//  ButtonTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ButtonTableViewCellDelegate: class {
    func buttonTapped()
}

// MARK: - Properties
class ButtonTableViewCell: UITableViewCell {
    private var button = CustomButton()

    var isButtonInteractable: Bool = true {
        didSet {
            isButtonInteractable ? button.makeInteractable() : button.makeUninteractable()
        }
    }

    weak var buttonTableViewCellDelegate: ButtonTableViewCellDelegate?

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
extension ButtonTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [button])
    }

    func setupViews() {
        selectionStyle = .none

        button.titleLabel?.font = .normal
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Funcs
extension ButtonTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    @objc private func buttonTapped() {
        buttonTableViewCellDelegate?.buttonTapped()
    }

    func configure(title: String, titleColor: UIColor = .black, backgroundColor: UIColor = .systemBlue) {
        button.title = title
        button.add(backgroundColor: backgroundColor, titleColor: titleColor)
        button.addCorner(style: .small)
    }
}
