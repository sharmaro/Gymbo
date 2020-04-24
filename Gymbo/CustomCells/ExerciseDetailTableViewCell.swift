//
//  ExerciseDetailTableViewCell
//  Gymbo
//
//  Created by Rohan Sharma on 8/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// Protocol for handling UITextField and UITextView interactions
protocol ExerciseDetailTableViewCellDelegate: class {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool
    func textFieldDidEndEditing(textField: UITextField, textFieldType: TextFieldType, cell: ExerciseDetailTableViewCell)
}

enum TextFieldType: String {
    case reps = "reps"
    case weight = "weight"
}

struct ExerciseDetailTableViewCellModel {
    var sets: String?
    var last: String?
    var reps: String?
    var weight: String?
    var isDoneButtonEnabled = false
}

// MARK: - Properties
class ExerciseDetailTableViewCell: UITableViewCell {
    private var stackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private var setsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var lastLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var repsTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = .numberPad
        textField.tag = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private var weightTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.keyboardType = .decimalPad
        textField.tag = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private var doneButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.text?.removeAll()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    weak var exerciseDetailCellDelegate: ExerciseDetailTableViewCellDelegate?

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    var didSelect = false {
        didSet {
            backgroundColor = didSelect ? .systemGreen : .clear
        }
    }

    private var isDoneButtonEnabled = false {
        didSet {
            let image = isDoneButtonEnabled ? UIImage(named: "checkmark") : nil
            doneButton.setImage(image, for: .normal)
            doneButton.isUserInteractionEnabled = isDoneButtonEnabled
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
extension ExerciseDetailTableViewCell {
    private func setup() {
        selectionStyle = .none

        addViews()
        setupConstraints()
        setupButtonTargets()
        setupTextFields()
    }

    private func addViews() {
        addSubviews(views: [stackView])
        stackView.addArrangedSubview(setsLabel)
        stackView.addArrangedSubview(lastLabel)
        stackView.addArrangedSubview(repsTextField)
        stackView.addArrangedSubview(weightTextField)
        stackView.addArrangedSubview(doneButton)
    }

    private func setupConstraints() {
        let stackViewBottomConstraint = stackView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
        stackViewBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([
            stackView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            stackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            stackViewBottomConstraint
        ])


        NSLayoutConstraint.activate([
            setsLabel.widthAnchor.constraint(equalToConstant: 40),
            lastLabel.widthAnchor.constraint(equalToConstant: 130),
            repsTextField.widthAnchor.constraint(equalToConstant: 45),
            weightTextField.widthAnchor.constraint(equalToConstant: 45),
            doneButton.widthAnchor.constraint(equalToConstant: 15),
            doneButton.heightAnchor.constraint(equalTo: doneButton.widthAnchor)
        ])
        stackView.layoutIfNeeded()
    }

    private func setupButtonTargets() {
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    private func setupTextFields() {
        [repsTextField, weightTextField].forEach {
            $0.font = .systemFont(ofSize: 15)
            $0.textAlignment = .center
            $0.layer.cornerRadius = 5
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
            $0.borderStyle = .none
            $0.delegate = self
        }
    }

    func configure(dataModel: ExerciseDetailTableViewCellModel) {
        setsLabel.text = dataModel.sets
        lastLabel.text = dataModel.last
        repsTextField.text = dataModel.reps
        weightTextField.text = dataModel.weight
        isDoneButtonEnabled = dataModel.isDoneButtonEnabled
    }

    @objc private func doneButtonTapped(_ sender: Any) {
        didSelect.toggle()
    }
}

// MARK: - UITextFieldDelegate
extension ExerciseDetailTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return exerciseDetailCellDelegate?.shouldChangeCharactersInTextField(textField: textField, replacementString: string) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var type: TextFieldType
        switch textField.tag {
        case 0:
            type = .reps
        case 1:
            type = .weight
        default:
            fatalError("Incorrect text field ended editing")
        }
        exerciseDetailCellDelegate?.textFieldDidEndEditing(textField: textField, textFieldType: type, cell: self)
    }
}
