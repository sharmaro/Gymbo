//
//  ButtonTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ButtonTableViewCell: UITableViewCell {
    private let button: CustomButton = {
        let button = CustomButton()
        button.titleLabel?.font = .normal
        return button
    }()

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
        contentView.add(subviews: [button])
    }

    func setupViews() {
        selectionStyle = .none

        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
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
        buttonTableViewCellDelegate?.buttonTapped(cell: self)
    }

    func configure(title: String, font: UIFont = .normal, titleColor: UIColor = .black, backgroundColor: UIColor = .systemBlue, cornerStyle: CornerStyle = .none) {
        button.title = title
        button.add(backgroundColor: backgroundColor, titleColor: titleColor)
        button.addCorner(style: cornerStyle)
    }
}
