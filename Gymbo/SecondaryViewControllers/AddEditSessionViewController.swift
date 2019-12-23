//
//  AddEditSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/3/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

enum SessionState: String {
    case add = "Add Session"
    case edit = "Edit Session"
}

class AddEditSessionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    class var id: String {
        return String(describing: self)
    }

    private lazy var sessionTableHeaderView: SessionTableHeaderView = {
        let sessionTableHeaderView = SessionTableHeaderView()
        sessionTableHeaderView.nameTextView.text = session.name ?? Constants.sessionNamePlaceholderText
        sessionTableHeaderView.infoTextView.text = session.info ?? Constants.sessionInfoPlaceholderText

        sessionTableHeaderView.sessionHeaderTextViewsDelegate = self
        sessionTableHeaderView.translatesAutoresizingMaskIntoConstraints = false

        [sessionTableHeaderView.nameTextView, sessionTableHeaderView.infoTextView].forEach {
            $0?.textColor = sessionState == .add ? Colors.dimmedBlack : .black
        }
        return sessionTableHeaderView
    }()

    private let realm = try? Realm()

    var session = Session()
    var sessionState = SessionState.add

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    private struct Constants {
        static let dimmedAlpha = CGFloat(0.3)
        static let normalAlpha = CGFloat(1)
        static let exerciseHeaderCellHeight = CGFloat(59)
        static let exerciseDetailCellHeight = CGFloat(32)
        static let addSetButtonCellHeight = CGFloat(50)

        static let sessionNamePlaceholderText = "Session name"
        static let sessionInfoPlaceholderText = "Info"
    }

    private struct Colors {
        static let dimmedBlack = UIColor.black.withAlphaComponent(0.2)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupTableHeaderView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard sessionTableHeaderView.nameTextView.textColor != Colors.dimmedBlack, let sessionName = sessionTableHeaderView.nameTextView.text, sessionName.count > 0  else {
            return
        }

        // Calls text field and text view didEndEditing() and saves data before realm object is saved
        view.endEditing(true)

        if sessionState == .add {
            sessionDataModelDelegate?.addSessionData(name: sessionName, info: sessionTableHeaderView.infoTextView.text, exercises: session.exercises)
        } else {
            try? realm?.write {
                session.name = sessionName
                session.info = sessionTableHeaderView.infoTextView.text
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        view.endEditing(true)
    }

    private func setupNavigationBar() {
        title = sessionState.rawValue
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+ Exercise", style: .plain, target: self, action: #selector(addExerciseButtonTapped))
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(ExerciseHeaderTableViewCell.nib, forCellReuseIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier)
        tableView.register(ExerciseDetailTableViewCell.nib, forCellReuseIdentifier: ExerciseDetailTableViewCell.reuseIdentifier)
        tableView.register(AddSetTableViewCell.nib, forCellReuseIdentifier: AddSetTableViewCell.reuseIdentifier)
    }

    private func setupTableHeaderView() {
        tableView.tableHeaderView = sessionTableHeaderView

        NSLayoutConstraint.activate([
            sessionTableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            sessionTableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            sessionTableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20),
            sessionTableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        sessionTableHeaderView.backgroundColor = .red

        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        guard let addExerciseViewController = storyboard?.instantiateViewController(withIdentifier: AddExerciseViewController.id) as? AddExerciseViewController else {
            return
        }

        let modalNavigationController = UINavigationController(rootViewController: addExerciseViewController)
        if #available(iOS 13.0, *) {
            // No op
        } else {
            modalNavigationController.modalPresentationStyle = .custom
            modalNavigationController.transitioningDelegate = self
        }
        addExerciseViewController.exerciseListDelegate = self
        if case .add = sessionState {
            present(modalNavigationController, animated: true, completion: nil)
        } else {
            addExerciseViewController.hideBarButtonItems = true
            navigationController?.pushViewController(addExerciseViewController, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource Funcs

extension AddEditSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return session.exercises.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        return session.exercises[section].sets + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0: // Exercise header cell
            if let exerciseHeaderCell = tableView.dequeueReusableCell(withIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseHeaderTableViewCell {
                exerciseHeaderCell.exerciseNameLabel.text = session.exercises[indexPath.section].name
                exerciseHeaderCell.doneButton.alpha = Constants.dimmedAlpha
                exerciseHeaderCell.exerciseHeaderCellDelegate = self

                return exerciseHeaderCell
            }
        case tableView.numberOfRows(inSection: indexPath.section) - 1: // Add set cell
            if let addSetCell = tableView.dequeueReusableCell(withIdentifier: AddSetTableViewCell.reuseIdentifier, for: indexPath) as? AddSetTableViewCell {
                addSetCell.addSetTableViewCellDelegate = self

                return addSetCell
            }
        default: // Exercise detail cell
            if let exerciseDetailCell = tableView.dequeueReusableCell(withIdentifier: ExerciseDetailTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseDetailTableViewCell {

                exerciseDetailCell.setsLabel.text = "\(indexPath.row)"
                if sessionState == .add {
                    exerciseDetailCell.lastLabel.text = "--"
                } else {
                    exerciseDetailCell.lastLabel.text = session.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].last ?? "--"
                }
                exerciseDetailCell.repsTextField.text = session.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].reps ?? ""
                exerciseDetailCell.weightTextField.text = session.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].weight ?? ""
                exerciseDetailCell.doneButton.alpha = Constants.dimmedAlpha
                exerciseDetailCell.exerciseDetailCellDelegate = self

                return exerciseDetailCell
            }
        }
        fatalError("Could not dequeue a valid cell for add/edit session table view")
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        // Protecting the first, second, and last rows because they shouldn't be swipe to delete
        case 0, 1, tableView.numberOfRows(inSection: indexPath.section) - 1:
            return false
        default:
            return true
        }
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

    private func removeSet(section: Int) {
        session.exercises[section].sets -= 1
        session.exercises[section].exerciseDetails.remove(at: section)
    }
}

// MARK: - UITableViewDelegate

extension AddEditSessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return Constants.exerciseHeaderCellHeight
        case tableView.numberOfRows(inSection: indexPath.section) - 1:
            return Constants.addSetButtonCellHeight
        default:
            return Constants.exerciseDetailCellHeight
        }
    }
}

// MARK: - DeleteExerciseButtonDelegate

extension AddEditSessionViewController: ExerciseHeaderCellDelegate {
    func deleteExerciseButtonTapped(cell: ExerciseHeaderTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        if sessionState == .add {
            session.exercises.remove(at: section)
        } else {
            try? realm?.write {
                session.exercises.remove(at: section)
            }
        }
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }
}

// MARK: - ExerciseDetailTableViewCellDelegate

extension AddEditSessionViewController: ExerciseDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 5
    }

    func textFieldDidEndEditing(textField: UITextField, textFieldType: TextFieldType, cell: ExerciseDetailTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let text = textField.text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise header cell
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
            session.exercises[section].exerciseDetails[row].reps = text
        case .weight:
            session.exercises[section].exerciseDetails[row].weight = text
        }
    }
}

// MARK: - AddSetTableViewCellDelegate

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

        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
        let sets = session.exercises[section].sets
        tableView.scrollToRow(at: IndexPath(row: sets + 1, section: section), at: .none, animated: true)
    }

    private func addSet(section: Int) {
        session.exercises[section].sets += 1
        session.exercises[section].exerciseDetails.append(ExerciseDetails())
    }
}

extension AddEditSessionViewController: ExerciseListDelegate {
    func updateExerciseList(_ exerciseTextList: [ExerciseText]) {
        for exerciseText in exerciseTextList {
            let newExercise = Exercise(name: exerciseText.exerciseName, muscleGroups: exerciseText.exerciseMuscles, sets: 1, exerciseDetails: List<ExerciseDetails>())
            if sessionState == .add {
                session.exercises.append(newExercise)
            } else {
                try? realm?.write {
                    session.exercises.append(newExercise)
                }
            }
        }
        tableView.reloadData()
    }
}

extension AddEditSessionViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension AddEditSessionViewController: SessionHeaderTextViewsDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Colors.dimmedBlack {
            textView.text.removeAll()
            textView.textColor = .black
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
            textView.text = textView.tag == 0 ? Constants.sessionNamePlaceholderText : Constants.sessionInfoPlaceholderText
            textView.textColor = Colors.dimmedBlack
        }

        if sessionState == .add {
            if textView.tag == 0 {
                session.name = textView.text
            } else {
                session.info = textView.text
            }
        } else {
            try? realm?.write {
                if textView.tag == 0 {
                    session.name = textView.text
                } else {
                    session.info = textView.text
                }
            }
        }
    }
}

