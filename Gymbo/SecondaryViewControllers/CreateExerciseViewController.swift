//
//  CreateExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol CreateExerciseDelegate: class {
    func addExercise(exerciseGroup: String, exerciseText: ExerciseText)
}

import UIKit

class CreateExerciseViewController: UIViewController {
    @IBOutlet private weak var infoContainerView: UIView!
    @IBOutlet private weak var exerciseGroupPickerView: UIPickerView!
    @IBOutlet private weak var exerciseNameTextField: UITextField!
    @IBOutlet private weak var exerciseMusclesTextField: UITextField!

    class var id: String {
        return String(describing: self)
    }

    weak var createExerciseDelegate: CreateExerciseDelegate?

    private let exerciseGroups = ["Abs", "Arms", "Back", "Buttocks", "Chest",
    "Hips", "Legs", "Shoulders", "Extra Exercises"]

    private struct Constants {
        static let navBarButtonSize = CGSize(width: 80, height: 30)

        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)

        static let title = "Create Exercise"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupContainerView()
        setupPickerView()
        setupTextFields()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    private func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        /// Only allow adding if both text fields are filled
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func setupContainerView() {
        infoContainerView.layer.cornerRadius = 10
        infoContainerView.layer.borderWidth = 1
        infoContainerView.layer.borderColor = UIColor.black.cgColor
    }

    private func setupPickerView() {
        exerciseGroupPickerView.dataSource = self
        exerciseGroupPickerView.delegate = self
    }

    private func setupTextFields() {
        exerciseNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        exerciseNameTextField.borderStyle = .none
        exerciseNameTextField.becomeFirstResponder()

        exerciseMusclesTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        exerciseMusclesTextField.borderStyle = .none
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func addButtonTapped() {
        guard let exercise = exerciseNameTextField.text, !exercise.isEmpty,
              let muscles = exerciseMusclesTextField.text, !muscles.isEmpty else {
            return
        }

        let selectedPickerRow = exerciseGroupPickerView.selectedRow(inComponent: 0)
        let exerciseGroup = exerciseGroups[selectedPickerRow]
        let exerciseText = ExerciseText(exerciseName: exerciseNameTextField.text, exerciseMuscles: exerciseMusclesTextField.text, isUserMade: true)
        createExerciseDelegate?.addExercise(exerciseGroup: exerciseGroup, exerciseText: exerciseText)

        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange() {
        guard let exerciseText = exerciseNameTextField.text, let muscleGroupsText = exerciseMusclesTextField.text else {
            return
        }
        let isTextFilled = (exerciseText.count > 0) && (muscleGroupsText.count > 0)

        navigationItem.rightBarButtonItem?.isEnabled = isTextFilled
        navigationItem.rightBarButtonItem?.customView?.alpha = isTextFilled ? Constants.activeAlpha : Constants.inactiveAlpha
    }
}

extension CreateExerciseViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        exerciseGroups.count
    }
}

extension CreateExerciseViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: pickerView.bounds.width, height: 25)))
        pickerLabel.text = exerciseGroups[row]
        pickerLabel.textColor = .black
        pickerLabel.textAlignment = .left
        pickerLabel.font = UIFont.systemFont(ofSize: 18)
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
}
