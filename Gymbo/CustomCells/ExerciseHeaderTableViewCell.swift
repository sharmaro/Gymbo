//
//  ExerciseNameTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/18/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseHeaderTableViewCell: UITableViewCell {
    // Header views
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .blue
        label.font = .normal
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let deleteButton: CustomButton = {
        let button = CustomButton()
        button.title = ""
        let image = UIImage(named: "delete")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    private let repsLabel =  UILabel()
    private let weightLabel =  UILabel()

    private let doneButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("", for: .normal)
        let image = UIImage(named: "checkmark")
        button.setImage(image, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let labelTexts = ["Sets", "Last", "Reps", "Lbs"]

    private var isDoneButtonImageHidden = false {
        didSet {
            let image = isDoneButtonImageHidden ? nil : UIImage(named: "checkmark")
            let text = isDoneButtonImageHidden ? "-" : nil

            doneButton.setImage(image, for: .normal)
            doneButton.setTitle(text, for: .normal)
            doneButton.isUserInteractionEnabled = !isDoneButtonImageHidden
        }
    }

    weak var exerciseHeaderCellDelegate: ExerciseHeaderCellDelegate?

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

        deleteButton.addCorner(style: .circle(length: deleteButton.frame.height))
    }
}

// MARK: - ViewAdding
extension ExerciseHeaderTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [nameLabel, deleteButton, infoStackView])
        infoStackView.addArrangedSubview(setsLabel)
        infoStackView.addArrangedSubview(lastLabel)
        infoStackView.addArrangedSubview(repsLabel)
        infoStackView.addArrangedSubview(weightLabel)
        infoStackView.addArrangedSubview(doneButton)
    }

    func setupViews() {
        selectionStyle = .none

        deleteButton.addTarget(self, action: #selector(deleteExerciseButtonTapped), for: .touchUpInside)

        var counter = 0
        [setsLabel, lastLabel, repsLabel, weightLabel].forEach {
            $0.text = labelTexts[counter]
            $0.font = .normal
            $0.textAlignment = .center
            $0.translatesAutoresizingMaskIntoConstraints = false
            counter += 1
        }

        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -10),
            nameLabel.bottomAnchor.constraint(equalTo: infoStackView.topAnchor, constant: -10),
            nameLabel.heightAnchor.constraint(equalToConstant: 22)
        ])

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            deleteButton.widthAnchor.constraint(equalToConstant: 15),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])

        let infoStackViewBottomConstraint = infoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        infoStackViewBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([
            infoStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            infoStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            infoStackViewBottomConstraint,
        ])

        NSLayoutConstraint.activate([
            setsLabel.widthAnchor.constraint(equalToConstant: 40),
            lastLabel.widthAnchor.constraint(equalToConstant: 130),
            repsLabel.widthAnchor.constraint(equalToConstant: 45),
            weightLabel.widthAnchor.constraint(equalToConstant: 45),
            doneButton.widthAnchor.constraint(equalToConstant: 15),
            doneButton.heightAnchor.constraint(equalTo: doneButton.widthAnchor)
        ])
        infoStackView.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension ExerciseHeaderTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(dataModel: ExerciseHeaderTableViewCellModel) {
        nameLabel.text = dataModel.name
        isDoneButtonImageHidden = dataModel.isDoneButtonImageHidden
    }

    @objc private func deleteExerciseButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.deleteExerciseButtonTapped(cell: self)
    }

    @objc private func doneButtonTapped(_ sender: Any) {
        exerciseHeaderCellDelegate?.exerciseDoneButtonTapped(cell: self)
    }
}
