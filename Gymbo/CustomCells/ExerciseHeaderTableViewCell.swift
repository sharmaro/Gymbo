//
//  ExerciseNameTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/18/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ExerciseHeaderCellDelegate: class {
    func deleteExerciseButtonTapped(cell: ExerciseHeaderTableViewCell)
    func exerciseDoneButtonTapped(cell: ExerciseHeaderTableViewCell)
}

struct ExerciseHeaderTableViewCellModel {
    var name: String?
    var isDoneButtonImageHidden = false
}

// MARK: - Properties
class ExerciseHeaderTableViewCell: UITableViewCell {
//    @IBOutlet private weak var exerciseNameLabel: UILabel!
//    @IBOutlet private weak var deleteExerciseButton: CustomButton!
//    // Exercise title views
//    @IBOutlet private weak var setsLabel: UILabel!
//    @IBOutlet private weak var lastLabel: UILabel!
//    @IBOutlet private weak var repsLabel: UILabel!
//    @IBOutlet private weak var weightLabel: UILabel!
//    @IBOutlet private weak var doneButton: UIButton!
    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .blue
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var deleteButton: CustomButton = {
        let customButton = CustomButton(frame: .zero)
        customButton.title = ""
        let image = UIImage(named: "delete")
        customButton.setImage(image, for: .normal)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        return customButton
    }()
    // Exercise title views
    private var infoStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var setsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Sets"
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var lastLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Last"
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var repsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Reps"
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var weightLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Lbs"
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var doneButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitle("", for: .normal)
        let image = UIImage(named: "checkmark")
        button.setImage(image, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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
}

// MARK: - Funcs
extension ExerciseHeaderTableViewCell {
    private func setup() {
        selectionStyle = .none

        addViews()
        addConstraints()
        setupViews()
    }

    private func addViews() {
        addSubviews(views: [nameLabel, deleteButton, infoStackView])
        infoStackView.addArrangedSubview(setsLabel)
        infoStackView.addArrangedSubview(lastLabel)
        infoStackView.addArrangedSubview(repsLabel)
        infoStackView.addArrangedSubview(weightLabel)
        infoStackView.addArrangedSubview(doneButton)
    }

    private func addConstraints() {
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

        let infoStackViewBottomConstraint = infoStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
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

    private func setupViews() {
        deleteButton.roundCorner(radius: deleteButton.bounds.width / 2)
        deleteButton.addTarget(self, action: #selector(deleteExerciseButtonTapped), for: .touchUpInside)

        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
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
