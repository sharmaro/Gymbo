//
//  ExerciseHeaderTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/18/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseHeaderTVCell: UITableViewCell {
    // Header views
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.medium.bold
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.sizeToFit()
        return label
    }()

    private let deleteButton: CustomButton = {
        let button = CustomButton()
        button.title = ""
        let image = UIImage(named: "delete")
        button.setImage(image, for: .normal)
        return button
    }()

    // Title views
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let setsLabel = UILabel()
    private let lastLabel = UILabel()
    private let repsLabel = UILabel()

    private let weightButton: ToggleButton = {
        let button = ToggleButton(items: WeightType.textItems)
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .xSmall)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let doneButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("", for: .normal)
        let image = UIImage(named: "checkmark")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.setTitleColor(.primaryText, for: .normal)
        button.tintColor = .primaryText
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let labelTexts = ["Sets", "Last", "Reps"]

    private var isDoneButtonImageHidden = false {
        didSet {
            let checkmarkImage = UIImage(named: "checkmark")?
                .withRenderingMode(.alwaysTemplate)
            let image = isDoneButtonImageHidden ? nil : checkmarkImage
            let text = isDoneButtonImageHidden ? "-" : nil

            doneButton.setImage(image, for: .normal)
            doneButton.setTitle(text, for: .normal)
            doneButton.isUserInteractionEnabled = !isDoneButtonImageHidden
        }
    }

    private var didLayoutSubviews = false

    var weightType: Int {
        WeightType.type(text: weightButton.title)
    }

    weak var exerciseHeaderCellDelegate: ExerciseHeaderCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UITableViewCell Var/Funcs
extension ExerciseHeaderTVCell {
    override func layoutSubviews() {
        super.layoutSubviews()

        if !didLayoutSubviews {
            deleteButton.addCorner(style: .circle(length: deleteButton.frame.height))
            didLayoutSubviews = true
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ExerciseHeaderTVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [nameLabel, deleteButton, infoStackView])
        infoStackView.addArrangedSubview(setsLabel)
        infoStackView.addArrangedSubview(lastLabel)
        infoStackView.addArrangedSubview(repsLabel)
        infoStackView.addArrangedSubview(weightButton)
        infoStackView.addArrangedSubview(doneButton)
    }

    func setupViews() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        var counter = 0
        [setsLabel, lastLabel, repsLabel].forEach {
            $0.text = labelTexts[counter]
            $0.font = .normal
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            counter += 1
        }

        weightButton.addTarget(self, action: #selector(weightButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        contentView.backgroundColor = .secondaryBackground
        [nameLabel, setsLabel, lastLabel, repsLabel].forEach { $0.textColor = .primaryText }
        doneButton.setTitleColor(.primaryText, for: .normal)
        doneButton.tintColor = .primaryText
    }

    //swiftlint:disable:next function_body_length
    func addConstraints() {
        let infoStackViewBottomConstraint = infoStackView.bottom.constraint(
            equalTo: bottom,
            constant: -10)
        infoStackViewBottomConstraint.priority = UILayoutPriority(rawValue: 999)

        NSLayoutConstraint.activate([
            nameLabel.top.constraint(
                equalTo: contentView.top,
                constant: 10),
            nameLabel.leading.constraint(
                equalTo: contentView.leading,
                constant: 16),
            nameLabel.trailing.constraint(
                equalTo: deleteButton.leading,
                constant: -10),
            nameLabel.bottom.constraint(
                equalTo: infoStackView.top,
                constant: -10),
            nameLabel.height.constraint(equalToConstant: 22),

            deleteButton.top.constraint(
                equalTo: contentView.top,
                constant: 10),
            deleteButton.trailing.constraint(
                equalTo: contentView.trailing,
                constant: -10),
            deleteButton.width.constraint(equalToConstant: 15),
            deleteButton.height.constraint(equalTo: deleteButton.width),

            infoStackView.leading.constraint(
                equalTo: contentView.leading,
                constant: 10),
            infoStackView.trailing.constraint(
                equalTo: contentView.trailing,
                constant: -10),
            infoStackViewBottomConstraint,

            setsLabel.width.constraint(equalToConstant: 40),
            lastLabel.width.constraint(equalToConstant: 130),
            repsLabel.width.constraint(equalToConstant: 45),
            weightButton.width.constraint(equalToConstant: 45),
            weightButton.height.constraint(equalToConstant: 25),
            doneButton.width.constraint(equalToConstant: 15),
            doneButton.height.constraint(equalTo: doneButton.width)
        ])
        infoStackView.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension ExerciseHeaderTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(dataModel: ExerciseHeaderTVCellModel) {
        nameLabel.text = dataModel.name
        if let weightTypeString = WeightType.init(rawValue: dataModel.weightType ?? 0)?.text {
            weightButton.setCurrentItem(item: weightTypeString)
        }
        isDoneButtonImageHidden = dataModel.isDoneButtonImageHidden
    }

    @objc private func deleteButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.deleteButtonTapped(cell: self)
    }

    @objc private func weightButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.weightButtonTapped(cell: self)
    }

    @objc private func doneButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.doneButtonTapped(cell: self)
    }
}
