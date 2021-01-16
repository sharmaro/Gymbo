//
//  ExerciseTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseTVCell: RoundedTVCell {
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
        roundedView.add(subviews: [muscleImageView, nameLabel, groupsLabel])
    }

    func setupViews() {
        [nameLabel, groupsLabel].forEach {
            $0.backgroundColor = .clear
            $0.numberOfLines = 1
            $0.minimumScaleFactor = 0.5
            $0.adjustsFontSizeToFitWidth = true
        }
    }

    func setupColors() {
        nameLabel.textColor = .primaryText
        groupsLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            muscleImageView.top.constraint(
                equalTo: roundedView.top,
                constant: 10),
            muscleImageView.leading.constraint(
                equalTo: roundedView.leading,
                constant: 20),
            muscleImageView.trailing.constraint(
                equalTo: nameLabel.leading,
                constant: -10),
            muscleImageView.trailing.constraint(
                equalTo: groupsLabel.leading,
                constant: -10),
            muscleImageView.bottom.constraint(
                equalTo: roundedView.bottom,
                constant: -10),
            muscleImageView.width.constraint(equalTo: muscleImageView.height),

            nameLabel.top.constraint(
                equalTo: roundedView.top,
                constant: 10),
            nameLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            nameLabel.bottom.constraint(equalTo: groupsLabel.top),

            groupsLabel.trailing.constraint(
                equalTo: roundedView.trailing,
                constant: -20),
            groupsLabel.bottom.constraint(
                equalTo: roundedView.bottom,
                constant: -10)
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
