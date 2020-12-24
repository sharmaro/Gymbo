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
    private let button = CustomButton()

    weak var buttonTableViewCellDelegate: ButtonTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension ButtonTableViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
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

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - Funcs
extension ButtonTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    @objc private func buttonTapped() {
        buttonTableViewCellDelegate?.buttonTapped(cell: self)
    }

    func configure(title: String,
                   font: UIFont = .normal,
                   titleColor: UIColor = .dynamicBlack,
                   backgroundColor: UIColor = .systemBlue,
                   cornerStyle: CornerStyle = .none) {
        button.title = title
        button.set(backgroundColor: backgroundColor, titleColor: titleColor)
        button.addCorner(style: cornerStyle)
    }

    func set(state: InteractionState, animated: Bool = true) {
        button.set(state: state, animated: animated)
    }
}
