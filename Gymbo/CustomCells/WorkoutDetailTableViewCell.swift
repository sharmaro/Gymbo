//
//  WorkoutDetailTableViewCell
//  Gymbo
//
//  Created by Rohan Sharma on 8/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// Protocol for handling UITextField and UITextView interactions
protocol WorkoutDetailTableViewCellDelegate: class {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool
    func textFieldDidEndEditing(textField: UITextField, textFieldType: TextFieldType, atIndexPath indexPath: IndexPath?)
}

enum TextFieldType: String {
    case reps = "reps"
    case weight = "weight"
    case time = "time"
}

class WorkoutDetailTableViewCell: UITableViewCell {
    // Workout title labels
    @IBOutlet private weak var setsLabel: UILabel!
    @IBOutlet private weak var repsLabel: UILabel!
    @IBOutlet private weak var weightLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!

    // Workout value labels
    @IBOutlet weak var setsValueLabel: UILabel!
    @IBOutlet weak var repsTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!

    weak var workoutDetailCellDelegate: WorkoutDetailTableViewCellDelegate?

    var indexPath: IndexPath?

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return "WorkoutDetailTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        selectionStyle = .none

        setupTextFields()
    }

    private func setupTextFields() {
        setsLabel.text = "Set"
        repsLabel.text = "Reps"
        weightLabel.text = "Weight"
        timeLabel.text = "Time"

        repsTextField.tag = 0
        weightTextField.tag = 1
        timeTextField.tag = 2

        repsTextField.keyboardType = .numberPad
        weightTextField.keyboardType = .decimalPad
        timeTextField.keyboardType = .numberPad

        [repsTextField, weightTextField, timeTextField].forEach {
            $0?.layer.cornerRadius = 5
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.black.cgColor
            $0?.borderStyle = .none

            $0?.delegate = self
        }
    }
}

extension WorkoutDetailTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return workoutDetailCellDelegate?.shouldChangeCharactersInTextField(textField: textField, replacementString: string) ?? true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        var type: TextFieldType
        switch textField.tag {
        case 0:
            type = .reps
        case 1:
            type = .weight
        case 2:
            type = .time
        default:
            fatalError("Incorrect text field ended editing")
        }
        workoutDetailCellDelegate?.textFieldDidEndEditing(textField: textField, textFieldType: type, atIndexPath: indexPath)
    }
}

