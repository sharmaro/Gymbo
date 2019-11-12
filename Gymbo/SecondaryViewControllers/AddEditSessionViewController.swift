//
//  AddEditSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/3/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

protocol WorkoutListDelegate: class {
    func updateWorkoutList(_ list: [ExerciseText])
}

enum SessionState: String {
    case add = "Add Session"
    case edit = "Edit Session"
}

class AddEditSessionViewController: UIViewController {
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseButton: CustomButton!

    private lazy var saveButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: CGSize(width: 45, height: 20)))
        button.setTitle("Save", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()

    private let realm = try? Realm()

    private var sessionNameTextFieldOriginY: CGFloat!

    var addEditSession = Session()
    var sessionState = SessionState.add

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    private struct Constants {
        static let headerViewHeight: CGFloat = 36
        static let footerViewHeight: CGFloat = 102

        static let additionalInfoTextViewHeight: CGFloat = 56
        static let addSetButtonHeight: CGFloat = 36

        static let workoutDetailTableViewCellHeight: CGFloat = 54

        static let textViewPlaceholderText = "Optional additional info"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSessionNameTextField()
        setupTableView()
        setupAddExerciseButton()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if sessionState == .edit {
            try? realm?.write {
                let sessionName = (sessionNameTextField.text?.count ?? 0) > 0 ? sessionNameTextField.text : "No session name"
                addEditSession.name = sessionName
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        view.endEditing(true)
    }

    private func setupNavigationBar() {
        title = sessionState.rawValue
        if sessionState == .add {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        }
    }

    private func setupSessionNameTextField() {
        sessionNameTextField.text = addEditSession.name
        sessionNameTextField.borderStyle = .none
        sessionNameTextField.delegate = self
        sessionNameTextField.returnKeyType = .done
        sessionNameTextField.becomeFirstResponder()

        sessionNameTextFieldOriginY = sessionNameTextField.frame.origin.y
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isHidden = addEditSession.workouts.count == 0
        tableView.keyboardDismissMode = .interactive
        tableView.register(WorkoutDetailTableViewCell.nib, forCellReuseIdentifier: WorkoutDetailTableViewCell.reuseIdentifier)
    }

    private func setupAddExerciseButton() {
        addExerciseButton.setTitle("+ Add Exercise", for: .normal)
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.addCornerRadius()
    }

    private func addSet(section: Int) {
        addEditSession.workouts[section].sets += 1
        addEditSession.workouts[section].workoutDetails.append(WorkoutDetails())
    }

    private func removeSet(section: Int) {
        addEditSession.workouts[section].sets -= 1
        addEditSession.workouts[section].workoutDetails.remove(at: section)
    }

    @objc private func saveButtonTapped(_ button: CustomButton) {
        // Calls text field and text view didEndEditing() and saves data before realm object is saved
        view.endEditing(true)

        let sessionName = (sessionNameTextField.text?.count ?? 0) > 0 ? sessionNameTextField.text : "No session name"
        sessionDataModelDelegate?.addSessionData(name: sessionName, workouts: addEditSession.workouts)

        navigationController?.popViewController(animated: true)
    }

    @objc private func addSetButtonTapped(_ button: UIButton) {
        let section = button.tag
        if sessionState == .add {
            addSet(section: section)
        } else {
            try? realm?.write {
                addSet(section: section)
            }
        }

        tableView.reloadData()
        let sets = addEditSession.workouts[section].sets
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

// MARK: - UITableViewDataSource Funcs

extension AddEditSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return addEditSession.workouts.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerContainerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: Constants.headerViewHeight)))
        headerContainerView.backgroundColor = .white

        let exerciseLabel = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: tableView.bounds.width - 40, height: Constants.headerViewHeight)))
        exerciseLabel.text = addEditSession.workouts[section].name
        exerciseLabel.textColor = .blue

        headerContainerView.addSubview(exerciseLabel)
        return headerContainerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.workoutDetailTableViewCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addEditSession.workouts[section].sets
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutDetailTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutDetailTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(WorkoutDetailTableViewCell.reuseIdentifier)`.")
        }

        cell.workoutDetailCellDelegate = self

        cell.setsValueLabel.text = "\(indexPath.row + 1)"
        cell.repsTextField.text = addEditSession.workouts[indexPath.section].workoutDetails[indexPath.row].reps ?? ""
        cell.weightTextField.text = addEditSession.workouts[indexPath.section].workoutDetails[indexPath.row].weight ?? ""
        cell.timeTextField.text = addEditSession.workouts[indexPath.section].workoutDetails[indexPath.row].time ?? ""
        cell.indexPath = indexPath

        return cell
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return Constants.footerViewHeight
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerContainerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: Constants.footerViewHeight)))
        footerContainerView.backgroundColor = .white

        let subviewWidth = tableView.bounds.width - 40

        let additionalInfoTextView = UITextView(frame: CGRect(origin: CGPoint(x: 20, y: 0), size: CGSize(width: subviewWidth, height: Constants.additionalInfoTextViewHeight)))
        additionalInfoTextView.layer.cornerRadius = 5
        additionalInfoTextView.layer.borderWidth = 1
        additionalInfoTextView.layer.borderColor = UIColor.black.cgColor
        additionalInfoTextView.text = addEditSession.workouts[section].additionalInfo ?? Constants.textViewPlaceholderText
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if sessionState == .add {
                removeSet(section: indexPath.section)
            } else {
                try? realm?.write {
                    removeSet(section: indexPath.section)
                }
            }
            tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate Funcs

extension AddEditSessionViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        if yOffset > 0 {
            sessionNameTextField.frame.origin.y = yOffset + sessionNameTextFieldOriginY
        }
    }
}

// MARK: - WorkoutDetailTableViewCellDelegate funcs

extension AddEditSessionViewController: WorkoutDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 6
    }

    private func saveTextFieldData(_ text: String, textFieldType: TextFieldType, indexPath: IndexPath) {
        switch textFieldType {
        case .reps:
            addEditSession.workouts[indexPath.section].workoutDetails[indexPath.row].reps = text
        case .weight:
            addEditSession.workouts[indexPath.section].workoutDetails[indexPath.row].weight = text
        case .time:
            addEditSession.workouts[indexPath.section].workoutDetails[indexPath.row].time = text
        }
    }

    func textFieldDidEndEditing(textField: UITextField, textFieldType: TextFieldType, atIndexPath indexPath: IndexPath?) {
        guard let indexPath = indexPath else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let text = textField.text ?? "--"
        if sessionState == .add {
            saveTextFieldData(text, textFieldType: textFieldType, indexPath: indexPath)
        } else {
            try? realm?.write {
                saveTextFieldData(text, textFieldType: textFieldType, indexPath: indexPath)
            }
        }
    }
}

// MARK: - UITextViewDelegate funcs

extension AddEditSessionViewController: UITextViewDelegate {
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

        if sessionState == .add {
            addEditSession.workouts[textView.tag].additionalInfo = textView.text
        } else {
            try? realm?.write {
                addEditSession.workouts[textView.tag].additionalInfo = textView.text
            }
        }
    }
}

extension AddEditSessionViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
        }
        return true
    }
}

extension AddEditSessionViewController: WorkoutListDelegate {
    func updateWorkoutList(_ exerciseTextList: [ExerciseText]) {
        for exerciseText in exerciseTextList {
            let newWorkout = Workout(name: exerciseText.exerciseName, muscleGroups: exerciseText.exerciseMuscles, sets: 1, workoutDetails: List<WorkoutDetails>())
            if sessionState == .add {
                addEditSession.workouts.append(newWorkout)
            } else {
                try? realm?.write {
                    addEditSession.workouts.append(newWorkout)
                }
            }
        }

        tableView.isHidden = addEditSession.workouts.count == 0
        tableView.reloadData()
    }
}

extension AddEditSessionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
