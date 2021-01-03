//
//  AllSessionsCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/1/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionsCVCell: UICollectionViewCell {
    private var containerVStack: UIStackView = {
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

    private var labelsHStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let imageAndTimeView = ImageAndLabelView()
    private let imageAndWeightView = ImageAndLabelView()

    private var exerciseTitleLabel: UILabel = {
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

// MARK: - Structs/Enums
private extension AllSessionsCVCell {
}

// MARK: - UIView Var/Funcs
extension AllSessionsCVCell {
    override var isHighlighted: Bool {
        didSet {
            Transform.caseFromBool(bool: isHighlighted).transform(view: self)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        nameLabel.text?.removeAll()
        dateLabel.text?.removeAll()
        imageAndTimeView.imageView.image = nil
        imageAndTimeView.label.text?.removeAll()
        imageAndWeightView.imageView.image = nil
        imageAndWeightView.label.text?.removeAll()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension AllSessionsCVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [containerVStack])

        [imageAndTimeView, imageAndWeightView].forEach {
            labelsHStackView.addArrangedSubview($0)
        }

        [nameLabel, dateLabel, labelsHStackView,
         exerciseTitleLabel, firstExerciseLabel].forEach {
            containerVStack.addArrangedSubview($0)
         }
    }

    func setupViews() {
        contentView.layer.addCorner(style: .small)
        contentView.addBorder(1, color: .dynamicDarkGray)
        contentView.addShadow(direction: .downRight)

        [dateLabel, firstExerciseLabel].forEach {
            $0.font = UIFont.normal.light
            $0.lineBreakMode = .byTruncatingTail
        }
    }

    func setupColors() {
        contentView.backgroundColor = .dynamicWhite
        contentView.layer.borderColor = UIColor.dynamicDarkGray.cgColor
        contentView.layer.shadowColor = UIColor.dynamicDarkGray.cgColor
        contentView.backgroundColor = .dynamicWhite

        [nameLabel, dateLabel, exerciseTitleLabel,
         firstExerciseLabel].forEach {
            $0.textColor = .dynamicBlack
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerVStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            containerVStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                     constant: 15),
            containerVStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                      constant: -15),

            labelsHStackView.leadingAnchor.constraint(equalTo: containerVStack.leadingAnchor),
            labelsHStackView.trailingAnchor.constraint(equalTo: containerVStack.trailingAnchor)
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
        imageAndTimeView.imageView.image = timeImage
        imageAndTimeView.imageView.tintColor = .dynamicBlack
        imageAndTimeView.label.text = timeString
        imageAndTimeView.label.font = UIFont.normal.light

        let weightText = "\(session.totalWeight) lbs"
        let weightImage = UIImage(named: "dumbbell")?
            .withRenderingMode(.alwaysTemplate)
        imageAndWeightView.imageView.image = weightImage
        imageAndWeightView.imageView.tintColor = .dynamicBlack
        imageAndWeightView.label.text = weightText
        imageAndWeightView.label.font = UIFont.normal.light
    }

    func configure(session: Session) {
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
