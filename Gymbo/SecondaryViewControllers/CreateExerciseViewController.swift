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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var exerciseGroupPickerView: UIPickerView!
    @IBOutlet weak var exerciseNameTextField: UITextField!
    @IBOutlet weak var exerciseMusclesTextField: UITextField!

    private lazy var closeButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Close", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var addButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Add", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.alpha = Constants.inactiveAlpha
        button.tag = 1
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    weak var createExerciseDelegate: CreateExerciseDelegate?

    private let exerciseGroups = ["Abs", "Arms", "Back", "Buttocks", "Chest",
    "Hips", "Legs", "Shoulders", "Extra Workouts"]

    private struct Constants {
        static let navBarButtonSize: CGSize = CGSize(width: 60, height: 20)

        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupContainerView()
        setupPickerView()
        setupTextFields()
    }

    private func setupNavigationBar() {
        navigationBar.prefersLargeTitles = false
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        addButton.isEnabled = false
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

    @objc private func navBarButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Cancel button tapped
            break
        case 1: // Add button tapped
            let selectedPickerRow = exerciseGroupPickerView.selectedRow(inComponent: 0)
            let exerciseGroup = exerciseGroups[selectedPickerRow]
            let exerciseText = ExerciseText(exerciseName: exerciseNameTextField.text, exerciseMuscles: exerciseMusclesTextField.text, isUserMade: true)
            createExerciseDelegate?.addExercise(exerciseGroup: exerciseGroup, exerciseText: exerciseText)
            break
        default:
            fatalError("Unrecognized navigation bar button pressed")
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange() {
        guard let exerciseText = exerciseNameTextField.text, let muscleGroupsText = exerciseMusclesTextField.text else {
            return
        }
        let isTextFilled = (exerciseText.count > 0) && (muscleGroupsText.count > 0)
        addButton.isEnabled = isTextFilled
        addButton.alpha = isTextFilled ? Constants.activeAlpha : Constants.inactiveAlpha
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
