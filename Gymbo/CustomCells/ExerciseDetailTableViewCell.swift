//
//  ExerciseDetailTableViewCell
//  Gymbo
//
//  Created by Rohan Sharma on 8/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExerciseDetailTableViewCell: UITableViewCell {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        return stackView
    }()

    private let setsLabel = UILabel()
    private let lastLabel = UILabel()

    private let repsTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.tag = 0
        return textField
    }()

    private let weightTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.tag = 1
        return textField
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.text?.removeAll()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    weak var exerciseDetailCellDelegate: ExerciseDetailTableViewCellDelegate?

    var didSelect = false {
        didSet {
            backgroundColor = didSelect ? .systemGreen : .clear
        }
    }

    var reps: String? {
        repsTextField.text
    }

    var weight: String? {
        weightTextField.text
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

// MARK: - UITableViewCell Var/Funcs
extension ExerciseDetailTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()

        didSelect = false
    }
}

// MARK: - ViewAdding
extension ExerciseDetailTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [stackView])
        stackView.addArrangedSubview(setsLabel)
        stackView.addArrangedSubview(lastLabel)
        stackView.addArrangedSubview(repsTextField)
        stackView.addArrangedSubview(weightTextField)
        stackView.addArrangedSubview(doneButton)
    }

    func setupViews() {
        selectionStyle = .none

        [setsLabel, lastLabel].forEach {
            $0.textAlignment = .center
            $0.font = .small
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [repsTextField, weightTextField].forEach {
            $0.font = .small
            $0.textAlignment = .center
            $0.borderStyle = .none
            $0.layer.addCorner(style: .xSmall)
            $0.addBorder(.defaultUnselectedBorder, color: .defaultUnselectedBorder)
            $0.delegate = self
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let repsTextFieldToolBar = UIToolbar()
        repsTextFieldToolBar.barStyle = .default
        repsTextFieldToolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextToolbarButtonTapped))
        ]
        repsTextFieldToolBar.sizeToFit()
        repsTextField.inputAccessoryView = repsTextFieldToolBar


        let weightTextFieldToolBar = UIToolbar()
        weightTextFieldToolBar.barStyle = .default
        weightTextFieldToolBar.items = [
            UIBarButtonItem(title: "Previous", style: .plain, target: self, action: #selector(previousToolbarButtonTapped)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneToolbarButtonTapped))
        ]
        weightTextFieldToolBar.sizeToFit()
        weightTextField.inputAccessoryView = weightTextFieldToolBar

        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        let stackViewBottomConstraint = stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
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

    @objc func nextToolbarButtonTapped() {
        weightTextField.becomeFirstResponder()
    }

    @objc func previousToolbarButtonTapped() {
        repsTextField.becomeFirstResponder()
    }

    @objc func doneToolbarButtonTapped() {
        endEditing(true)
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
        Haptic.shared.sendImpactFeedback(.medium)
        didSelect.toggle()
    }
}

// MARK: - UITextFieldDelegate
extension ExerciseDetailTableViewCell: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.animateBorderColorAndWidth(fromColor: .defaultUnselectedBorder, toColor: .defaultSelectedBorder, fromWidth: .defaultUnselectedBorder, toWidth: .defaultSelectedBorder)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        exerciseDetailCellDelegate?.shouldChangeCharactersInTextField(textField: textField, replacementString: string) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.animateBorderColorAndWidth(fromColor: .defaultSelectedBorder, toColor: .defaultUnselectedBorder, fromWidth: .defaultSelectedBorder, toWidth: .defaultUnselectedBorder)

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
