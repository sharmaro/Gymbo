//
//  ExerciseTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// Protocol for handling UITextField and UITextView interactions
protocol ExerciseTableViewCellDelegate: class {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool
    func didEndEditingTextField(textField: UITextField, textFieldType: TextFieldType, atIndexPath indexPath: IndexPath?)
    
    func didBeginEditingTextView(textView: UITextView)
    func shouldChangeCharactersInTextView(textView: UITextView, replacementText text: String) -> Bool
    func didEndEditingTextView(textView: UITextView, atIndexPath indexPath: IndexPath?)
}

enum TextFieldType: String {
    case reps = "reps"
    case weight = "weight"
    case time = "time"
}

class ExerciseTableViewCell: UITableViewCell {
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
    
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    weak var exerciseCellDelegate: ExerciseTableViewCellDelegate?
    
    private let textViewPlaceholderText = "Add optional additional info here"
    
    var indexPath: IndexPath?
    
    override var reuseIdentifier: String {
        return "ExerciseTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTextFields()
        setupTextView()
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
    
    private func setupTextView() {
        additionalInfoTextView.layer.cornerRadius = 5
        additionalInfoTextView.layer.borderWidth = 1
        additionalInfoTextView.layer.borderColor = UIColor.black.cgColor
        
        additionalInfoTextView.text = textViewPlaceholderText
        additionalInfoTextView.textColor = UIColor.black.withAlphaComponent(0.2)
        additionalInfoTextView.returnKeyType = .done
        
        additionalInfoTextView.delegate = self
    }
}

extension ExerciseTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return exerciseCellDelegate?.shouldChangeCharactersInTextField(textField: textField, replacementString: string) ?? true
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
        exerciseCellDelegate?.didEndEditingTextField(textField: textField, textFieldType: type, atIndexPath: indexPath)
    }
}

extension ExerciseTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        exerciseCellDelegate?.didBeginEditingTextView(textView: textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return exerciseCellDelegate?.shouldChangeCharactersInTextView(textView: textView, replacementText: text) ?? true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        exerciseCellDelegate?.didEndEditingTextView(textView: textView, atIndexPath: indexPath)
    }
}
