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

class ExerciseDetailTableViewCell: UITableViewCell {
    // MARK: - Properties
    // Exercise value labels
    @IBOutlet private weak var setsLabel: UILabel!
    @IBOutlet private weak var lastLabel: UILabel!
    @IBOutlet private weak var repsTextField: UITextField!
    @IBOutlet private weak var weightTextField: UITextField!
    @IBOutlet private weak var doneButton: UIButton!

    weak var exerciseDetailCellDelegate: ExerciseDetailTableViewCellDelegate?

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

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
}

// MARK: - UITableViewCell Var/Funcs
extension ExerciseDetailTableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupTextFields()
        setupDoneButton()
    }
}

// MARK: - Funcs
extension ExerciseDetailTableViewCell {
    private func setupTextFields() {
        repsTextField.tag = 0
        weightTextField.tag = 1

        repsTextField.keyboardType = .numberPad
        weightTextField.keyboardType = .decimalPad

        [repsTextField, weightTextField].forEach {
            $0?.layer.cornerRadius = 5
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.black.cgColor
            $0?.borderStyle = .none
            $0?.delegate = self
        }
    }

    private func setupDoneButton() {
        doneButton.setTitleColor(.black, for: .normal)
    }

    func configure(dataModel: ExerciseDetailTableViewCellModel) {
        setsLabel.text = dataModel.sets
        lastLabel.text = dataModel.last
        repsTextField.text = dataModel.reps
        weightTextField.text = dataModel.weight
        isDoneButtonEnabled = dataModel.isDoneButtonEnabled
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
