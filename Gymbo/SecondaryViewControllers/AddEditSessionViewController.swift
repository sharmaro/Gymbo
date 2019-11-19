//
//  AddEditSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/3/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

protocol ExerciseListDelegate: class {
    func updateExerciseList(_ list: [ExerciseText])
}

enum SessionState: String {
    case add = "Add Session"
    case edit = "Edit Session"
}

class AddEditSessionViewController: UIViewController {
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!

    private lazy var addExerciseButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: CGSize(width: 80, height: 30)))
        button.setTitle("+ Exercise", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)
        return button
    }()

    private let realm = try? Realm()

    private var sessionNameTextFieldOriginY: CGFloat = 0
    private var infoTextViewOriginY: CGFloat = 0

    var addEditSession = Session()
    var sessionState = SessionState.add

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    private struct Constants {
        static let exerciseNameCellHeight: CGFloat = 36
        static let addSetButtonCellHeight: CGFloat = 36
        static let exerciseDetailTableViewCellHeight: CGFloat = 54

        static let textViewPlaceholderText = "Info"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSessionNameTextField()
        setupInfoTextView()
        setupTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let sessionName = sessionNameTextField.text, sessionName.count > 0  else {
            return
        }

        // Calls text field and text view didEndEditing() and saves data before realm object is saved
        view.endEditing(true)

        if sessionState == .add {
            sessionDataModelDelegate?.addSessionData(name: sessionName, info: infoTextView.text, exercises: addEditSession.exercises)
        } else {
            try? realm?.write {
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addExerciseButton)
    }

    private func setupSessionNameTextField() {
        sessionNameTextField.text = addEditSession.name
        sessionNameTextField.borderStyle = .none
        sessionNameTextField.delegate = self
        sessionNameTextField.returnKeyType = .done
        sessionNameTextField.becomeFirstResponder()

        sessionNameTextFieldOriginY = sessionNameTextField.frame.origin.y
    }

    private func setupInfoTextView() {
        infoTextView.textContainerInset = .zero
        infoTextView.textContainer.lineFragmentPadding = 0
        infoTextView.text = addEditSession.info ?? Constants.textViewPlaceholderText
        if infoTextView.text == Constants.textViewPlaceholderText {
            infoTextView.textColor = UIColor.black.withAlphaComponent(0.2)
        }
        infoTextView.returnKeyType = .done
        infoTextView.delegate = self

        infoTextViewOriginY = infoTextView.frame.origin.y
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isHidden = addEditSession.exercises.count == 0
        tableView.keyboardDismissMode = .interactive
        tableView.register(ExerciseNameTableViewCell.nib, forCellReuseIdentifier: ExerciseNameTableViewCell.reuseIdentifier)
        tableView.register(ExerciseDetailTableViewCell.nib, forCellReuseIdentifier: ExerciseDetailTableViewCell.reuseIdentifier)
        tableView.register(AddSetTableViewCell.nib, forCellReuseIdentifier: AddSetTableViewCell.reuseIdentifier)
    }

    private func addSet(section: Int) {
        addEditSession.exercises[section].sets += 1
        addEditSession.exercises[section].exerciseDetails.append(ExerciseDetails())
    }

    private func removeSet(section: Int) {
        addEditSession.exercises[section].sets -= 1
        addEditSession.exercises[section].exerciseDetails.remove(at: section)
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        if let addExerciseViewController = storyboard?.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {

            let navigationController = UINavigationController(rootViewController: addExerciseViewController)
            if #available(iOS 13.0, *) {
                // No op
            } else {
                navigationController.modalPresentationStyle = .custom
                navigationController.transitioningDelegate = self
            }
            addExerciseViewController.exerciseListDelegate = self
            present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource Funcs

extension AddEditSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return addEditSession.exercises.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return Constants.exerciseNameCellHeight
        case tableView.numberOfRows(inSection: indexPath.section) - 1:
            return Constants.addSetButtonCellHeight
        default:
            return Constants.exerciseDetailTableViewCellHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        return addEditSession.exercises[section].sets + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // Exercise name label cell
            if let exerciseCell = tableView.dequeueReusableCell(withIdentifier: ExerciseNameTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseNameTableViewCell {
                exerciseCell.exerciseNameLabel.text = addEditSession.exercises[indexPath.section].name
                exerciseCell.deleteExerciseButtonDelegate = self

                return exerciseCell
            }
        case tableView.numberOfRows(inSection: indexPath.section) - 1: // Add set cell
            if let addSetCell = tableView.dequeueReusableCell(withIdentifier: AddSetTableViewCell.reuseIdentifier, for: indexPath) as? AddSetTableViewCell {
                addSetCell.addSetTableViewCellDelegate = self

                return addSetCell
            }
        default: // Exercise detail cell
            if let exerciseDetailCell = tableView.dequeueReusableCell(withIdentifier: ExerciseDetailTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseDetailTableViewCell {

                exerciseDetailCell.setsValueLabel.text = "\(indexPath.row)"
                exerciseDetailCell.repsTextField.text = addEditSession.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].reps ?? ""
                exerciseDetailCell.weightTextField.text = addEditSession.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].weight ?? ""
                exerciseDetailCell.timeTextField.text = addEditSession.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].time ?? ""

                exerciseDetailCell.exerciseDetailCellDelegate = self

                return exerciseDetailCell
            }
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row > 0 && indexPath.row < (tableView.numberOfRows(inSection: indexPath.section) - 1)
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
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

// MARK: - UITableViewDelegate Funcs

extension AddEditSessionViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        if yOffset > 0 {
            sessionNameTextField.frame.origin.y = yOffset + sessionNameTextFieldOriginY
            infoTextView.frame.origin.y = yOffset + infoTextViewOriginY
        }
    }
}

// MARK: - ExerciseDetailTableViewCellDelegate funcs

extension AddEditSessionViewController: ExerciseDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 6
    }

    func textFieldDidEndEditing(textField: UITextField, textFieldType: TextFieldType, cell: ExerciseDetailTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let text = textField.text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise name cell
        if sessionState == .add {
            saveTextFieldData(text, textFieldType: textFieldType, section: indexPath.section, row: indexPath.row - 1)
        } else {
            try? realm?.write {
                saveTextFieldData(text, textFieldType: textFieldType, section: indexPath.section, row: indexPath.row - 1)
            }
        }
    }

    private func saveTextFieldData(_ text: String, textFieldType: TextFieldType, section: Int, row: Int) {
        switch textFieldType {
        case .reps:
            addEditSession.exercises[section].exerciseDetails[row].reps = text
        case .weight:
            addEditSession.exercises[section].exerciseDetails[row].weight = text
        case .time:
            addEditSession.exercises[section].exerciseDetails[row].time = text
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
            addEditSession.info = textView.text
        } else {
            try? realm?.write {
                addEditSession.info = textView.text
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

extension AddEditSessionViewController: ExerciseListDelegate {
    func updateExerciseList(_ exerciseTextList: [ExerciseText]) {
        for exerciseText in exerciseTextList {
            let newExercise = Exercise(name: exerciseText.exerciseName, muscleGroups: exerciseText.exerciseMuscles, sets: 1, exerciseDetails: List<ExerciseDetails>())
            if sessionState == .add {
                addEditSession.exercises.append(newExercise)
            } else {
                try? realm?.write {
                    addEditSession.exercises.append(newExercise)
                }
            }
        }

        tableView.isHidden = addEditSession.exercises.count == 0
        tableView.reloadData()
    }
}

extension AddEditSessionViewController: AddSetTableViewCellDelegate {
    func addSetButtonTapped(cell: AddSetTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        if sessionState == .add {
            addSet(section: section)
        } else {
            try? realm?.write {
                addSet(section: section)
            }
        }

        tableView.reloadData()
        let sets = addEditSession.exercises[section].sets
        tableView.scrollToRow(at: IndexPath(row: sets - 1, section: section), at: .bottom, animated: true)
    }
}

extension AddEditSessionViewController: DeleteExerciseButtonDelegate {
    func deleteExerciseButtonTapped(cell: ExerciseNameTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        if sessionState == .add {
            addEditSession.exercises.remove(at: section)
        } else {
            try? realm?.write {
                addEditSession.exercises.remove(at: section)
            }
        }

        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }
}

extension AddEditSessionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
