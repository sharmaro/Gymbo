//
//  ProfileTitleTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/31/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileTitleTVCell: RoundedTVCell {
    private let profileImageButton: CustomButton = {
        let button = CustomButton()
        button.contentMode = .scaleAspectFit
        button.addCorner(style: .circle(length: 70))
        button.addBorder(1, color: .primaryText)
        return button
    }()

    private let labelStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalCentering
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium.bold
        return label
    }()

    private let descriptionLabel: UILabel = {
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
        roundedView.add(subviews: [profileImageButton, labelStackView])
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
        profileImageButton.layer.borderColor = profileImageButton.layer.borderColor
        nameLabel.textColor = .primaryText
        descriptionLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            profileImageButton.topAnchor.constraint(equalTo: roundedView.topAnchor,
                                                    constant: 15),
            profileImageButton.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor,
                                                        constant: 20),
            profileImageButton.trailingAnchor.constraint(equalTo: labelStackView.leadingAnchor,
                                                         constant: -15),
            profileImageButton.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor,
                                                       constant: -15),
            profileImageButton.widthAnchor.constraint(equalTo: profileImageButton.heightAnchor),

            labelStackView.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor,
                                                constant: -20)
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
        UIView.transition(with: profileImageButton,
                          duration: .defaultAnimationTime,
                          options: .transitionCrossDissolve,
                          animations: { [weak self] in
            self?.profileImageButton.setImage(updatedImage, for: .normal)
        })
    }
}
