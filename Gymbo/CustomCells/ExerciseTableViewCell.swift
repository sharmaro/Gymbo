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

    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var musclesLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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

// MARK: - Funcs
extension ExerciseTableViewCell {
    private func setup() {
        selectionStyle = .none

        addMainViews()
        addConstraints()
    }

    private func addMainViews() {
        contentView.addSubviews(views: [nameLabel, musclesLabel])
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.safeAreaLayoutGuide.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameLabel.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nameLabel.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nameLabel.bottomAnchor.constraint(equalTo: musclesLabel.topAnchor)
        ])

        NSLayoutConstraint.activate([
            musclesLabel.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            musclesLabel.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            musclesLabel.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }

    func configure(dataModel: ExerciseText) {
        nameLabel.text = dataModel.name
        musclesLabel.text = dataModel.muscles
        isUserMade = dataModel.isUserMade
    }
}
