//
//  CreateExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol CreateExerciseDelegate: class {
    func addCreatedExercise(exerciseGroup: String, exerciseText: ExerciseText)
}

// MARK: - Properties
class CreateExerciseViewController: UIViewController {
    @IBOutlet private weak var exerciseGroupPickerView: UIPickerView!
    @IBOutlet private weak var exerciseNameTextField: UITextField!
    @IBOutlet private weak var exerciseMusclesTextField: UITextField!

    class var id: String {
        return String(describing: self)
    }

    weak var createExerciseDelegate: CreateExerciseDelegate?
    weak var setAlphaDelegate: SetAlphaDelegate?
}

// MARK: - Structs/Enums
private extension CreateExerciseViewController {
    struct Constants {
        static let title = "Create Exercise"

        static let navBarButtonSize = CGSize(width: 80, height: 30)

        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateExerciseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupPickerView()
        setupTextFields()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }
}

// MARK: - Funcs
extension CreateExerciseViewController {
    private func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        // Only allow adding if both text fields are filled
        navigationItem.rightBarButtonItem?.isEnabled = false
    }


    private func setupPickerView() {
        exerciseGroupPickerView.dataSource = self
        exerciseGroupPickerView.delegate = self
    }

    private func setupTextFields() {
        [exerciseNameTextField, exerciseMusclesTextField].forEach {
            $0?.borderStyle = .none
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }
        exerciseNameTextField.autocapitalizationType = .words
        exerciseNameTextField.returnKeyType = .next
        exerciseNameTextField.becomeFirstResponder()

        exerciseMusclesTextField.returnKeyType = .done
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
        setAlphaDelegate?.setAlpha(alpha: 1)
    }

    @objc private func addButtonTapped() {
        guard let exercise = exerciseNameTextField.text, !exercise.isEmpty,
              let muscles = exerciseMusclesTextField.text, !muscles.isEmpty else {
            return
        }

        let selectedPickerRow = exerciseGroupPickerView.selectedRow(inComponent: 0)
        let exerciseGroup = ExerciseDataModel.shared.exerciseGroups[selectedPickerRow]
        let exerciseText = ExerciseText(exerciseName: exercise, exerciseMuscles: muscles, isUserMade: true)
        createExerciseDelegate?.addCreatedExercise(exerciseGroup: exerciseGroup, exerciseText: exerciseText)

        dismiss(animated: true)
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        guard let exerciseText = exerciseNameTextField.text, let muscleGroupsText = exerciseMusclesTextField.text else {
            return
        }

        let isTextComplete = (exerciseText.count > 0) && (muscleGroupsText.count > 0)
        navigationItem.rightBarButtonItem?.isEnabled = isTextComplete
        navigationItem.rightBarButtonItem?.customView?.alpha = isTextComplete ? Constants.activeAlpha : Constants.inactiveAlpha
    }
}

// MARK: - UIPickerViewDataSource
extension CreateExerciseViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        ExerciseDataModel.shared.exerciseGroups.count
    }
}

// MARK: - UIPickerViewDelegate
extension CreateExerciseViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: pickerView.bounds.width, height: 25)))
        pickerLabel.text = ExerciseDataModel.shared.exerciseGroups[row]
        pickerLabel.textColor = .black
        pickerLabel.textAlignment = .left
        pickerLabel.font = UIFont.systemFont(ofSize: 18)
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
}

// MARK: - UITextFieldDelegate
extension CreateExerciseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == exerciseNameTextField {
            exerciseMusclesTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
