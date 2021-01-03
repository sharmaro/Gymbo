//
//  ProfileTitleTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/31/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileTitleTVCell: UITableViewCell {
    private var profileImageButton: CustomButton = {
        let button = CustomButton()
        button.contentMode = .scaleAspectFit
        button.addCorner(style: .circle(length: 70))
        button.addBorder(1, color: .dynamicBlack)
        return button
    }()

    private var labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

    private var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium.bold
        return label
    }()

    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normal.light
        return label
    }()

    private let defaultImage = UIImage(named: "add")

    weak var imageButtonDelegate: ImageButtonDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension ProfileTitleTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ProfileTitleTVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [profileImageButton, labelStackView])
        [nameLabel, descriptionLabel].forEach {
            labelStackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        profileImageButton.addTarget(self, action: #selector(imageButtonTapped),
                                     for: .touchUpInside)
        [nameLabel, descriptionLabel].forEach {
            $0.backgroundColor = .clear
            $0.minimumScaleFactor = 0.7
            $0.adjustsFontSizeToFitWidth = true
            $0.lineBreakMode = .byCharWrapping
        }
    }

    func setupColors() {
        contentView.backgroundColor = .dynamicWhite
        profileImageButton.layer.borderColor = profileImageButton.layer.borderColor
        [nameLabel, descriptionLabel].forEach { $0.textColor = .dynamicBlack }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: contentView.topAnchor,
                                                    constant: 15),
            profileImageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                        constant: 15),
            profileImageButton.trailingAnchor.constraint(equalTo: labelStackView.leadingAnchor,
                                                         constant: -15),
            profileImageButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                                       constant: -15),
            profileImageButton.widthAnchor.constraint(equalTo: profileImageButton.heightAnchor),

            labelStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                constant: 15)
        ])
    }
}

// MARK: - Funcs
extension ProfileTitleTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    @objc private func imageButtonTapped(_ sender: Any) {
        guard let button = sender as? CustomButton else {
            return
        }

        let function: ButtonFunction = button.image(for: .normal) == defaultImage ? .add : .update
        imageButtonDelegate?.buttonTapped(cell: self, index: -1, function: function)
    }

    func configure(image: UIImage, name: String, description: String) {
        profileImageButton.setImage(image, for: .normal)
        nameLabel.text = name
        descriptionLabel.text = description
    }

    func update(image: UIImage? = nil) {
        let updatedImage = image == nil ? defaultImage : image
        profileImageButton.setImage(updatedImage, for: .normal)
    }
}
