//
//  AllSessionsCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/1/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionsCVCell: RoundedCVCell {
    private var indexLabel = UILabel()

    private let containerVStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        return stackView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium.bold
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let dateLabel = UILabel()

    private let labelsHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()

    private let imageAndDurationView = ImageAndLabelView()
    private let imageAndWeightView = ImageAndLabelView()

    private let exerciseTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Exercise"
        label.font = UIFont.medium.bold
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let firstExerciseLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension AllSessionsCVCell {
    override func prepareForReuse() {
        super.prepareForReuse()

        [indexLabel, nameLabel, dateLabel].forEach {
            $0.text?.removeAll()
        }
        [imageAndDurationView, imageAndWeightView].forEach {
            $0.imageView.image = nil
            $0.label.text?.removeAll()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension AllSessionsCVCell: ViewAdding {
    func addViews() {
        roundedView.add(subviews: [indexLabel, containerVStack])
        [imageAndDurationView, imageAndWeightView].forEach {
            labelsHStackView.addArrangedSubview($0)
        }

        [nameLabel, dateLabel, labelsHStackView,
         exerciseTitleLabel, firstExerciseLabel].forEach {
            containerVStack.addArrangedSubview($0)
        }
    }

    func setupViews() {
        indexLabel.font = UIFont.medium.semibold
        [dateLabel, firstExerciseLabel].forEach {
            $0.font = UIFont.normal.light
            $0.lineBreakMode = .byTruncatingTail
        }
    }

    func setupColors() {
        [indexLabel, nameLabel, dateLabel, exerciseTitleLabel,
         firstExerciseLabel].forEach {
            $0.textColor = .primaryText
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            indexLabel.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
            indexLabel.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor,
                                                constant: 20),
            indexLabel.trailingAnchor.constraint(equalTo: containerVStack.leadingAnchor,
                                                constant: -15),

            containerVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -20)
        ])
    }
}

// MARK: - Funcs
extension AllSessionsCVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    private func setupImageAndLabelViews(session: Session) {
        let timeString = session.sessionSeconds.neatTimeString
        let timeImage = UIImage(named: "stopwatch")?
            .withRenderingMode(.alwaysTemplate)
        imageAndDurationView.imageView.image = timeImage
        imageAndDurationView.imageView.tintColor = .primaryText
        imageAndDurationView.label.text = timeString
        imageAndDurationView.label.font = UIFont.normal.light

        let weightText = "\(session.totalWeight) lbs"
        let weightImage = UIImage(named: "dumbbell")?
            .withRenderingMode(.alwaysTemplate)
        imageAndWeightView.imageView.image = weightImage
        imageAndWeightView.imageView.tintColor = .primaryText
        imageAndWeightView.label.text = weightText
        imageAndWeightView.label.font = UIFont.normal.light
    }

    func configure(index: Int, session: Session) {
        indexLabel.text = "\(index)"
        indexLabel.sizeToFit()
        nameLabel.text = session.name
        dateLabel.text = session.dateCompleted?.formattedString(type: .medium)

        setupImageAndLabelViews(session: session)

        if session.exercises.isEmpty {
            firstExerciseLabel.text = "No exercises..."
        } else {
            let firstExercise = session.exercises[0]
            let sets = "\(firstExercise.sets)"
            let exerciseName = firstExercise.name ?? ""
            firstExerciseLabel.text = "\(sets) x \(exerciseName)"
        }
    }
}
