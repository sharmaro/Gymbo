//
//  CreateExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/9/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol CreateExerciseDelegate: class {
    func addExercise(exercise: String, muscleGroups: String)
}

import UIKit

class CreateExerciseViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var exerciseNameTextField: UITextField!
    @IBOutlet weak var muscleGroupsTextField: UITextField!

    private lazy var closeButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Constants.navBarButtonSize))
        button.setTitle("Close", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var addButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Constants.navBarButtonSize))
        button.setTitle("Add", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.alpha = Constants.inactiveAlpha
        button.tag = 1
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    weak var createExerciseDelegate: CreateExerciseDelegate?

    private struct Constants {
        static let navBarButtonSize: CGSize = CGSize(width: 60, height: 20)

        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        [exerciseNameTextField, muscleGroupsTextField].forEach {
            setupTextField($0)
        }

    }

    private func setupNavigationBar() {
        navigationBar.prefersLargeTitles = false
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: closeButton)
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        addButton.isEnabled = false
    }

    private func setupTextField(_ textField: UITextField) {
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }

    @objc private func navBarButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Cancel button tapped
            break
        case 1: // Add button tapped
            createExerciseDelegate?.addExercise(exercise: exerciseNameTextField.text ?? "", muscleGroups: muscleGroupsTextField.text ?? "")
        default:
            fatalError("Unrecognized navigation bar button pressed")
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange() {
        guard let exerciseText = exerciseNameTextField.text, let muscleGroupsText = muscleGroupsTextField.text else {
            return
        }
        let isTextFilled = (exerciseText.count > 0) && (muscleGroupsText.count > 0)
        addButton.isEnabled = isTextFilled
        addButton.alpha = isTextFilled ? Constants.activeAlpha : Constants.inactiveAlpha
    }
}
