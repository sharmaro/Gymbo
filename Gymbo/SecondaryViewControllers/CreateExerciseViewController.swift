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
    private var pickerView = UIPickerView(frame: .zero)
    private var nameTextField = UITextField(frame: .zero)
    private var musclesTextField = UITextField(frame: .zero)

    weak var createExerciseDelegate: CreateExerciseDelegate?
    weak var setAlphaDelegate: SetAlphaDelegate?
}

// MARK: - Structs/Enums
private extension CreateExerciseViewController {
    struct Constants {
        static let title = "Create Exercise"

        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)
    }
}

// MARK: - ViewAdding
extension CreateExerciseViewController: ViewAdding {
    func addViews() {
        view.add(subViews: [pickerView, nameTextField, musclesTextField])
    }

    func setupViews() {
        view.backgroundColor = .white

        pickerView.dataSource = self
        pickerView.delegate = self

        [nameTextField, musclesTextField].forEach {
            $0.borderStyle = .none
            $0.delegate = self
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }

        nameTextField.placeholder = "Exercise name..."
        nameTextField.autocapitalizationType = .words
        nameTextField.returnKeyType = .next
        nameTextField.becomeFirstResponder()

        musclesTextField.placeholder = "Relevant muscles..."
        musclesTextField.returnKeyType = .done
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            pickerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            pickerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            pickerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            pickerView.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: -15)
        ])

        NSLayoutConstraint.activate([
            nameTextField.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            nameTextField.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            nameTextField.bottomAnchor.constraint(equalTo: musclesTextField.topAnchor, constant: -15),
            nameTextField.heightAnchor.constraint(equalToConstant: 45)
        ])

        NSLayoutConstraint.activate([
            musclesTextField.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            musclesTextField.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            musclesTextField.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            musclesTextField.heightAnchor.constraint(equalTo: nameTextField.heightAnchor)
        ])
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateExerciseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()
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

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
        setAlphaDelegate?.setAlpha(alpha: 1)
    }

    @objc private func addButtonTapped() {
        guard let exercise = nameTextField.text, !exercise.isEmpty,
              let muscles = musclesTextField.text, !muscles.isEmpty else {
            return
        }

        let selectedPickerRow = pickerView.selectedRow(inComponent: 0)
        let exerciseGroup = ExerciseDataModel.shared.exerciseGroups[selectedPickerRow]
        let exerciseText = ExerciseText(name: exercise, muscles: muscles, isUserMade: true)
        createExerciseDelegate?.addCreatedExercise(exerciseGroup: exerciseGroup, exerciseText: exerciseText)

        dismiss(animated: true)
    }

    @objc private func textFieldDidChange(textField: UITextField) {
        guard let exerciseText = nameTextField.text,
            let muscleGroupsText = musclesTextField.text else {
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
        pickerLabel.font = .medium
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
}

// MARK: - UITextFieldDelegate
extension CreateExerciseViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            musclesTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}
