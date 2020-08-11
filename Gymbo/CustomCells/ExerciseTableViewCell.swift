//
//  ExerciseTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseTableViewCell: UITableViewCell {
    private let muscleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.addBorder(1, color: .systemRed)
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .normal
        return label
    }()

    private let groupsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.small.light
        return label
    }()

    var exerciseName: String? {
        return nameLabel.text
    }

    var didSelect = false {
        didSet {
            backgroundColor = didSelect ? .systemGray : .white
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        muscleImageView.addCorner(style: .circle(length: muscleImageView.frame.height))
    }
}

// MARK: - ViewAdding
extension ExerciseTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [muscleImageView, nameLabel, groupsLabel])
    }

    func setupViews() {
        [nameLabel, groupsLabel].forEach {
            $0.numberOfLines = 1
            $0.minimumScaleFactor = 0.5
            $0.adjustsFontSizeToFitWidth = true
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            muscleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            muscleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            muscleImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -5),
            muscleImageView.trailingAnchor.constraint(equalTo: groupsLabel.leadingAnchor, constant: -5),
            muscleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
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
extension ExerciseTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(dataModel: Exercise) {
        nameLabel.text = dataModel.name
        groupsLabel.text = dataModel.groups

        let imagesData = dataModel.imagesData
        if let firstImageData = imagesData.first,
            let image = UIImage(data: firstImageData) {
            muscleImageView.image = image
        } else if let emptyImage = UIImage(named: "empty") {
            muscleImageView.image = emptyImage
        }
    }
}
