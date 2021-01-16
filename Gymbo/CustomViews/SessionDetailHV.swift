//
//  SessionDetailHV.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionDetailHV: UIView {
    private let firstTextLabel = UILabel()
    private let secondTextLabel = UILabel()
    private let dateLabel = UILabel()
    private let timeLabel = UILabel()
    private let imageAndDurationView = ImageAndLabelView()
    private let imageAndWeightView = ImageAndLabelView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension SessionDetailHV {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionDetailHV: ViewAdding {
    func addViews() {
        add(subviews: [firstTextLabel, secondTextLabel, dateLabel,
                       timeLabel, imageAndDurationView,
                       imageAndWeightView])
    }

    func setupViews() {
        [firstTextLabel, secondTextLabel, dateLabel, timeLabel].forEach {
            $0.numberOfLines = 0
        }

        firstTextLabel.font = UIFont.xLarge.medium
        secondTextLabel.font = UIFont.medium.medium
        dateLabel.font = UIFont.normal.light
        timeLabel.font = UIFont.normal.light
    }

    func setupColors() {
        backgroundColor = .clear
        [firstTextLabel, secondTextLabel].forEach {
            $0.textColor = .primaryText
        }
        [dateLabel, timeLabel].forEach { $0.textColor = .secondaryText }
        imageAndDurationView.label.textColor = .secondaryText
        imageAndWeightView.label.textColor = .secondaryText
    }

    //swiftlint:disable:next function_body_length
    func addConstraints() {
        NSLayoutConstraint.activate([
            firstTextLabel.top.constraint(equalTo: top),
            firstTextLabel.leading.constraint(
                equalTo: leading,
                constant: 16),
            firstTextLabel.trailing.constraint(
                equalTo: trailing,
                constant: -20),
            firstTextLabel.bottom.constraint(
                equalTo: secondTextLabel.top,
                constant: -2),

            secondTextLabel.leading.constraint(
                equalTo: leading,
                constant: 16),
            secondTextLabel.trailing.constraint(
                equalTo: trailing,
                constant: -20),
            secondTextLabel.bottom.constraint(
                equalTo: dateLabel.top,
                constant: -2),

            dateLabel.leading.constraint(
                equalTo: leading,
                constant: 16),
            dateLabel.trailing.constraint(
                equalTo: trailing,
                constant: -20),
            dateLabel.bottom.constraint(
                equalTo: timeLabel.top,
                constant: -2),

            timeLabel.leading.constraint(
                equalTo: leading,
                constant: 16),
            timeLabel.trailing.constraint(
                equalTo: trailing,
                constant: -20),
            timeLabel.bottom.constraint(
                equalTo: imageAndDurationView.top,
                constant: -2),
            timeLabel.bottom.constraint(
                equalTo: imageAndWeightView.top,
                constant: -2),

            imageAndDurationView.leading.constraint(
                equalTo: leading,
                constant: 16),
            imageAndDurationView.trailing.constraint(
                equalTo: imageAndWeightView.leading,
                constant: -10),
            imageAndDurationView.bottom.constraint(
                equalTo: bottom,
                constant: -10),

            imageAndWeightView.bottom.constraint(
                equalTo: bottom,
                constant: -10)
        ])
    }
}

// MARK: - Funcs
extension SessionDetailHV {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    private func setupImageAndLabelViews(dataModel: SessionDetailHeaderModel) {
        imageAndDurationView.imageView.image = dataModel.firstImage
        imageAndDurationView.imageView.tintColor = .secondaryText
        imageAndDurationView.label.text = dataModel.firstImageText
        imageAndDurationView.label.font = UIFont.normal.light

        imageAndWeightView.imageView.image = dataModel.secondImage
        imageAndWeightView.imageView.tintColor = .secondaryText
        imageAndWeightView.label.text = dataModel.secondImageText
        imageAndWeightView.label.font = UIFont.normal.light
    }

    func configure(dataModel: SessionDetailHeaderModel) {
        firstTextLabel.text = dataModel.firstText
        secondTextLabel.text = dataModel.secondText
        let dateText = dataModel.dateText?.components(separatedBy: "\n")
        dateLabel.text = dateText?.first ?? ""
        timeLabel.text = dateText?.last ?? ""
        setupImageAndLabelViews(dataModel: dataModel)
    }
}
