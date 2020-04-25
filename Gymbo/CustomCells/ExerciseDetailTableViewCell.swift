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
    private var stackView = UIStackView(frame: .zero)
    private var setsLabel = UILabel(frame: .zero)
    private var lastLabel = UILabel(frame: .zero)
    private var repsTextField = UITextField(frame: .zero)
    private var weightTextField = UITextField(frame: .zero)
    private var doneButton = UIButton(frame: .zero)

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

// MARK: - ViewAdding
extension ExerciseDetailTableViewCell: ViewAdding {
    func addViews() {
        add(subViews: [stackView])
        stackView.addArrangedSubview(setsLabel)
        stackView.addArrangedSubview(lastLabel)
        stackView.addArrangedSubview(repsTextField)
        stackView.addArrangedSubview(weightTextField)
        stackView.addArrangedSubview(doneButton)
    }

    func setupViews() {
        selectionStyle = .none

        stackView.alignment = .center
        stackView.distribution = .equalSpacing

        [setsLabel, lastLabel].forEach {
            $0.textAlignment = .center
            $0.font = .systemFont(ofSize: 15)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        repsTextField.keyboardType = .numberPad
        repsTextField.tag = 0

        weightTextField.keyboardType = .decimalPad
        weightTextField.tag = 1

        [repsTextField, weightTextField].forEach {
            $0.font = .systemFont(ofSize: 15)
            $0.textAlignment = .center
            $0.layer.cornerRadius = 5
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.black.cgColor
            $0.borderStyle = .none
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        doneButton.setTitleColor(.black, for: .normal)
        doneButton.titleLabel?.text?.removeAll()
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        let stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        stackViewBottomConstraint.priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
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
}

// MARK: - Funcs
extension ExerciseDetailTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
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
