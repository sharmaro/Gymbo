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
    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private lazy var nameLabel = UILabel(frame: .zero)
    private lazy var musclesLabel = UILabel(frame: .zero)

    private var isUserMade = false {
        didSet {
            backgroundColor = isUserMade ? .systemBlue : .white
        }
    }

    var exerciseName: String? {
        return nameLabel.text
    }

    var didSelect = false {
        didSet {
            let defaultColor: UIColor = isUserMade ? .systemBlue : .white
            backgroundColor = didSelect ? .systemGray : defaultColor
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
}

// MARK: - ViewAdding
extension ExerciseTableViewCell: ViewAdding {
    func addViews() {
        add(subViews: [nameLabel, musclesLabel])
    }

    func setupViews() {
        selectionStyle = .none

        nameLabel.font = .medium

        musclesLabel.textColor = .darkGray
        musclesLabel.font = UIFont.small.light
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            nameLabel.bottomAnchor.constraint(equalTo: musclesLabel.topAnchor)
        ])

        NSLayoutConstraint.activate([
            musclesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
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

    func configure(dataModel: ExerciseText) {
        nameLabel.text = dataModel.name
        musclesLabel.text = dataModel.muscles
        isUserMade = dataModel.isUserMade
    }
}
