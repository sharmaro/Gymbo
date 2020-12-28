//
//  ExerciseTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseTVCell: UITableViewCell {
    private let muscleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.addBorder(1, color: .systemRed)
        imageView.addCorner(style: .small)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .normal
        return label
    }()

    private let groupsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.small.light
        return label
    }()

    var exerciseName: String? {
        return nameLabel.text
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension ExerciseTVCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ExerciseTVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [muscleImageView, nameLabel, groupsLabel])
    }

    func setupViews() {
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .dynamicLightGray

        [nameLabel, groupsLabel].forEach {
            $0.backgroundColor = .clear
            $0.numberOfLines = 1
            $0.minimumScaleFactor = 0.5
            $0.adjustsFontSizeToFitWidth = true
        }
    }

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        nameLabel.textColor = .dynamicBlack
        groupsLabel.textColor = .dynamicDarkGray
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            muscleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            muscleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            muscleImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -10),
            muscleImageView.trailingAnchor.constraint(equalTo: groupsLabel.leadingAnchor, constant: -10),
            muscleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            muscleImageView.widthAnchor.constraint(equalTo: muscleImageView.heightAnchor),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            nameLabel.bottomAnchor.constraint(equalTo: groupsLabel.topAnchor),

            groupsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            groupsLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension ExerciseTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(dataModel: Exercise) {
        nameLabel.text = dataModel.name
        groupsLabel.text = dataModel.groups

        // Only want the first image for the thumbnail
        let directory: Directory = dataModel.isUserMade ?
            .userThumbnails : .stockThumbnails
        let thumbnailNames = dataModel.imageNames
        if let firstThumbnailName = thumbnailNames.first,
           let image = Utility.getImageFrom(name: firstThumbnailName,
                                            directory: directory) {
            muscleImageView.contentMode = .scaleToFill
            muscleImageView.image = image
        } else if let emptyImage = UIImage(named: "empty") {
            muscleImageView.contentMode = .center
            muscleImageView.image = emptyImage
        }
    }
}
