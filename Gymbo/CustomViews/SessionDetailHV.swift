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
    private let imageAndTimeView = ImageAndLabelView()
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
                       imageAndTimeView, imageAndWeightView])
    }

    func setupViews() {
        [firstTextLabel, secondTextLabel, dateLabel].forEach {
            $0.textColor = .dynamicBlack
            $0.numberOfLines = 0
        }

        firstTextLabel.font = UIFont.xLarge.medium
        secondTextLabel.font = UIFont.medium.medium
        dateLabel.font = UIFont.normal.light
    }

    func setupColors() {
        backgroundColor = .clear
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            firstTextLabel.topAnchor.constraint(equalTo: topAnchor),
            firstTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: 16),
            firstTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -20),
            firstTextLabel.bottomAnchor.constraint(equalTo: secondTextLabel.topAnchor,
                                                   constant: -2),

            secondTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: 16),
            secondTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -20),
            secondTextLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor,
                                                    constant: -2),

            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -20),
            dateLabel.bottomAnchor.constraint(equalTo: imageAndTimeView.topAnchor,
                                              constant: -2),

            imageAndTimeView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                      constant: 16),
            imageAndTimeView.trailingAnchor.constraint(equalTo: imageAndWeightView.leadingAnchor,
                                                       constant: -10),
            imageAndTimeView.bottomAnchor.constraint(equalTo: bottomAnchor,
                                                     constant: -10),

            imageAndWeightView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                       constant: -20),
            imageAndWeightView.bottomAnchor.constraint(equalTo: bottomAnchor,
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
        imageAndTimeView.imageView.image = dataModel.firstImage
        imageAndTimeView.imageView.tintColor = .dynamicBlack
        imageAndTimeView.label.text = dataModel.firstImageText
        imageAndTimeView.label.font = UIFont.normal.light

        imageAndWeightView.imageView.image = dataModel.secondImage
        imageAndWeightView.imageView.tintColor = .dynamicBlack
        imageAndWeightView.label.text = dataModel.secondImageText
        imageAndWeightView.label.font = UIFont.normal.light
    }

    func configure(dataModel: SessionDetailHeaderModel) {
        firstTextLabel.text = dataModel.firstText
        secondTextLabel.text = dataModel.secondText
        dateLabel.text = dataModel.dateText
        setupImageAndLabelViews(dataModel: dataModel)
    }
}
