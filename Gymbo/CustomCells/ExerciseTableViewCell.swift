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
    private var muscleImageView = UIImageView(frame: .zero)
    private var nameLabel = UILabel(frame: .zero)
    private var musclesLabel = UILabel(frame: .zero)

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

        muscleImageView.addCorner(style: .circle(view: muscleImageView))
    }
}

// MARK: - ReuseIdentifying
extension ExerciseTableViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension ExerciseTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [muscleImageView, nameLabel, musclesLabel])
    }

    func setupViews() {
        separatorInset.left = 15

        muscleImageView.contentMode = .scaleToFill
        muscleImageView.layer.borderWidth = 1
        muscleImageView.layer.borderColor = UIColor.systemRed.cgColor

        nameLabel.font = .normal

        musclesLabel.textColor = .darkGray
        musclesLabel.font = UIFont.small.light

        [nameLabel, musclesLabel].forEach {
            $0.numberOfLines = 1
            $0.minimumScaleFactor = 0.5
            $0.adjustsFontSizeToFitWidth = true
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            muscleImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            muscleImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            muscleImageView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -5),
            muscleImageView.trailingAnchor.constraint(equalTo: musclesLabel.leadingAnchor, constant: -5),
            muscleImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            muscleImageView.widthAnchor.constraint(equalTo: muscleImageView.heightAnchor)
        ])

        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameLabel.bottomAnchor.constraint(equalTo: musclesLabel.topAnchor)
        ])

        NSLayoutConstraint.activate([
            musclesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            musclesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
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

    func configure(dataModel: ExerciseInfo) {
        nameLabel.text = dataModel.name
        musclesLabel.text = dataModel.muscles

        let imagesData = dataModel.imagesData
        if let firstImageData = imagesData.first,
            let image = UIImage(data: firstImageData) {
            muscleImageView.image = image
        } else if let emptyImage = UIImage(named: "emptyImage") {
            muscleImageView.image = emptyImage
        }
    }
}
