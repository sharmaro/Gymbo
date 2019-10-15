//
//  AddSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/6/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//


protocol WorkoutListDelegate: class {
    func updateWorkoutList(_ list: [ExerciseText])
}

import UIKit
import RealmSwift

class AddSessionViewController: UIViewController {
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseButton: CustomButton!

    private lazy var saveButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 45, height: 20)))
        button.setTitle("Save", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private var sessionNameTextFieldOriginY: CGFloat!

    private var workoutList = List<Workout>()

    private struct Constants {
        static let headerViewHeight: CGFloat = 36
        static let footerViewHeight: CGFloat = 102

        static let additionalInfoTextViewHeight: CGFloat = 56
        static let addSetButtonHeight: CGFloat = 36

        static let workoutDetailTableViewCellHeight: CGFloat = 54

        static let textViewPlaceholderText = "Optional additional info"
    }

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Session"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)

        sessionNameTextFieldOriginY = sessionNameTextField.frame.origin.y
        sessionNameTextField.borderStyle = .none
        sessionNameTextField.delegate = self
        sessionNameTextField.returnKeyType = .done
        sessionNameTextField.becomeFirstResponder()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isHidden = workoutList.count == 0
        tableView.keyboardDismissMode = .interactive
        tableView.register(WorkoutDetailTableViewCell.nib, forCellReuseIdentifier: WorkoutDetailTableViewCell.reuseIdentifier)

        addExerciseButton.setTitle("+ Add Exercise", for: .normal)
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.addCornerRadius()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        view.endEditing(true)
    }

    @objc func saveButtonTapped(_ button: CustomButton) {
        // Calls text field and text view didEndEditing() and sets data before realm object is saved
        view.endEditing(true)

        let sessionName = (sessionNameTextField.text?.count ?? 0) > 0 ? sessionNameTextField.text : "No session name"
        sessionDataModelDelegate?.saveSessionData(name: sessionName, workouts: workoutList)
        navigationController?.popViewController(animated: true)
    }

    @objc private func addSetButtonTapped(_ button: UIButton) {
        let section = button.tag

        var numberOfSets = workoutList[section].sets
        numberOfSets += 1
        workoutList[section].sets = numberOfSets

        let newWorkoutDetails = WorkoutDetails()
        workoutList[section].workoutDetails.append(newWorkoutDetails)
        tableView.reloadData()

        let sets = workoutList[section].sets
        tableView.scrollToRow(at: IndexPath(row: sets - 1, section: section), at: .none, animated: true)
    }

    @IBAction func addExerciseButtonTapped(_ sender: Any) {
        if sender is UIButton,
            let addExerciseViewController = storyboard?.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {

            if #available(iOS 13.0, *) {
                // No op
            } else {
                addExerciseViewController.modalPresentationStyle = .custom
                addExerciseViewController.transitioningDelegate = self
            }
            addExerciseViewController.workoutListDelegate = self
            present(addExerciseViewController, animated: true, completion: nil)
        }
    }
}

extension AddSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return workoutList.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.bounds.width, height: Constants.headerViewHeight)))
        headerContainerView.backgroundColor = .white

        let exerciseLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: tableView.bounds.width - 40, height: Constants.headerViewHeight)))
        exerciseLabel.text = workoutList[section].name
        exerciseLabel.textColor = .blue

        headerContainerView.addSubview(exerciseLabel)
        return headerContainerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.workoutDetailTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutList[section].sets
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutDetailTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(WorkoutDetailTableViewCell.reuseIdentifier)`.")
        }

        cell.workoutDetailCellDelegate = self

        cell.setsValueLabel.text = "\(indexPath.row + 1)"
        cell.repsTextField.text = workoutList[indexPath.section].workoutDetails[indexPath.row].reps ?? ""
        cell.weightTextField.text = workoutList[indexPath.section].workoutDetails[indexPath.row].weight ?? ""
        cell.timeTextField.text = workoutList[indexPath.section].workoutDetails[indexPath.row].time ?? ""
        cell.indexPath = indexPath

        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.footerViewHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: tableView.bounds.width, height: Constants.footerViewHeight)))
        footerContainerView.backgroundColor = .white

        let subviewWidth = tableView.bounds.width - 40

        let additionalInfoTextView = UITextView(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: subviewWidth, height: Constants.additionalInfoTextViewHeight)))
        additionalInfoTextView.layer.cornerRadius = 5
        additionalInfoTextView.layer.borderWidth = 1
        additionalInfoTextView.layer.borderColor = UIColor.black.cgColor
        additionalInfoTextView.text = workoutList[section].additionalInfo ?? Constants.textViewPlaceholderText
        if additionalInfoTextView.text == Constants.textViewPlaceholderText {
            additionalInfoTextView.textColor = UIColor.black.withAlphaComponent(0.2)
        }
        additionalInfoTextView.returnKeyType = .done
        additionalInfoTextView.tag = section
        additionalInfoTextView.delegate = self
        footerContainerView.addSubview(additionalInfoTextView)

        let addSetButton = CustomButton(frame: CGRect(origin: CGPoint(x: 20, y: Constants.additionalInfoTextViewHeight + 10), size: CGSize(width: subviewWidth, height: Constants.addSetButtonHeight)))
        addSetButton.setTitle("Add Set", for: .normal)
        addSetButton.addCornerRadius()
        addSetButton.tag = section
        addSetButton.addTarget(self, action: #selector(addSetButtonTapped), for: .touchUpInside)
        footerContainerView.addSubview(addSetButton)

        return footerContainerView
    }
}

extension AddSessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell at index path: \(indexPath).")
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        if yOffset > 0 {
            sessionNameTextField.frame.origin.y = yOffset + sessionNameTextFieldOriginY
        }
    }
}

// MARK: - WorkoutDetailTableViewCellDelegate funcs

extension AddSessionViewController: WorkoutDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 6
    }

    func didEndEditingTextField(textField: UITextField, textFieldType: TextFieldType, atIndexPath indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            fatalError("Found nil index path for text field after it ended editing")
        }

        var textFieldText = "--"
        if let text = textField.text, text.count > 0 {
            textFieldText = text
        }

        switch textFieldType {
        case .reps:
            workoutList[indexPath.section].workoutDetails[indexPath.row].reps = textFieldText
        case .weight:
            workoutList[indexPath.section].workoutDetails[indexPath.row].weight = textFieldText
        case .time:
            workoutList[indexPath.section].workoutDetails[indexPath.row].time = textFieldText
        }
    }
}

// MARK: - UITextViewDelegate funcs

extension AddSessionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == Constants.textViewPlaceholderText {
            textView.text.removeAll()
            textView.textColor = UIColor.black.withAlphaComponent(1)
        }
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = Constants.textViewPlaceholderText
            textView.textColor = UIColor.black.withAlphaComponent(0.2)
        }

        workoutList[textView.tag].additionalInfo = textView.text
    }
}

extension AddSessionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension AddSessionViewController: WorkoutListDelegate {
    func updateWorkoutList(_ exerciseTextList: [ExerciseText]) {
        for exerciseText in exerciseTextList {
            workoutList.append(Workout(name: exerciseText.exerciseName, muscleGroups: exerciseText.muscleGroups, sets: 1, workoutDetails: List<WorkoutDetails>()))
        }

        tableView.isHidden = workoutList.count == 0
        tableView.reloadData()
    }
}

extension AddSessionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
