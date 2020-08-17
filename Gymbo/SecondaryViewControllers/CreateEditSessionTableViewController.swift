//
//  CreateEditSessionTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/3/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
class CreateEditSessionTableViewController: UITableViewController {
    private let tableHeaderView = SessionHeaderView()

    private let realm = try? Realm()

    var session = Session()
    var sessionState = SessionState.create

    private var didAddSet = false
    private var previousExerciseDetailInformation: (reps: String?, weight: String?) = ("", "")

    weak var sessionDataModelDelegate: SessionDataModelDelegate?
}

// MARK: - Structs/Enums
private extension CreateEditSessionTableViewController {
    struct Constants {
        static let exerciseHeaderCellHeight = CGFloat(59)
        static let exerciseDetailCellHeight = CGFloat(40)
        static let buttonCellHeight = CGFloat(55)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "Info"
        static let buttonText = "+ Set"

        static let dimmedBlack = UIColor.black.withAlphaComponent(0.2)
    }
}

// MARK: - ViewAdding
extension CreateEditSessionTableViewController: ViewAdding {
    func setupNavigationBar() {
        title = sessionState.rawValue
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+ Exercise",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(addExerciseButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        view.backgroundColor = .white

        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.register(ExerciseHeaderTableViewCell.self,
                           forCellReuseIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier)
        tableView.register(ExerciseDetailTableViewCell.self,
                           forCellReuseIdentifier: ExerciseDetailTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self,
                           forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)

        if mainTabBarController?.isSessionInProgress ?? false {
            tableView.contentInset.bottom = minimizedHeight
        }

        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session.name ?? Constants.namePlaceholderText
        dataModel.secondText = session.info ?? Constants.infoPlaceholderText
        dataModel.textColor = sessionState == .create ? Constants.dimmedBlack : .black

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = true
        tableHeaderView.customTextViewDelegate = self
    }

    func addConstraints() {
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = tableHeaderView
        NSLayoutConstraint.activate([
            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            tableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20),
            tableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditSessionTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        addConstraints()
        registerForKeyboardNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        tableHeaderView.makeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard tableHeaderView.isFirstTextValid,
            let sessionName = tableHeaderView.firstText else {
            view.endEditing(true)
            return
        }

        // Calls text field and text view didEndEditing() and saves data
        view.endEditing(true)

        let sessionToInteractWith = Session(name: sessionName,
                                            info: tableHeaderView.secondText,
                                            exercises: session.exercises)
        if sessionState == .create {
            sessionDataModelDelegate?.create(sessionToInteractWith, success: {
                // No op
            }, fail: { [weak self] in
                DispatchQueue.main.async {
                    self?.presentCustomAlert(title: "Oops!",
                                             content: "\(sessionName) already exists!",
                                             usesBothButtons: false,
                                             rightButtonTitle: "Sad!")
                }
            })
        } else {
            sessionDataModelDelegate?.update(session.name ?? "", session: sessionToInteractWith, success: {
                // No op
            }, fail: { [weak self] in
                DispatchQueue.main.async {
                    self?.presentCustomAlert(title: "Oops!",
                                             content: "Couldn't update session \(self?.session.name ?? "").",
                                             usesBothButtons: false,
                                             rightButtonTitle: "Sad!")
                }
            })
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension CreateEditSessionTableViewController {
    private func getExerciseHeaderTableViewCell(for indexPath: IndexPath) -> ExerciseHeaderTableViewCell {
        guard let exerciseHeaderTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier,
            for: indexPath) as? ExerciseHeaderTableViewCell else {
            fatalError("Could not dequeue \(ExerciseHeaderTableViewCell.reuseIdentifier)")
        }

        var dataModel = ExerciseHeaderTableViewCellModel()
        dataModel.name = session.exercises[indexPath.section].name
        dataModel.weightType = session.exercises[indexPath.section].weightType
        dataModel.isDoneButtonImageHidden = true

        exerciseHeaderTableViewCell.configure(dataModel: dataModel)
        exerciseHeaderTableViewCell.exerciseHeaderCellDelegate = self
        return exerciseHeaderTableViewCell
    }

    private func getButtonTableViewCell(for indexPath: IndexPath) -> ButtonTableViewCell {
        guard let buttonTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ButtonTableViewCell.reuseIdentifier,
            for: indexPath) as? ButtonTableViewCell else {
            fatalError("Could not dequeue \(ButtonTableViewCell.reuseIdentifier)")
        }

        buttonTableViewCell.configure(title: Constants.buttonText,
                                      titleColor: .white,
                                      backgroundColor: .systemGray,
                                      cornerStyle: .small)
        buttonTableViewCell.buttonTableViewCellDelegate = self
        return buttonTableViewCell
    }

    private func getExerciseDetailTableViewCell(for indexPath: IndexPath) -> ExerciseDetailTableViewCell {
        guard let exerciseDetailCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseDetailTableViewCell.reuseIdentifier,
            for: indexPath) as? ExerciseDetailTableViewCell else {
            fatalError("Could not dequeue \(ExerciseDetailTableViewCell.reuseIdentifier)")
        }

        let indexPathToUse = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        var dataModel = ExerciseDetailTableViewCellModel()
        dataModel.sets = "\(indexPath.row)"
        let exercise = session.exercises[indexPath.section]
        dataModel.last = exercise.exerciseDetails[indexPath.row - 1].last ?? "--"
        dataModel.isDoneButtonEnabled = false
        if didAddSet {
            dataModel.reps = previousExerciseDetailInformation.reps
            dataModel.weight = previousExerciseDetailInformation.weight

            saveTextFieldsWithOrWithoutRealm(text: dataModel.reps,
                                             textFieldType: .reps,
                                             indexPath: indexPathToUse)
            saveTextFieldsWithOrWithoutRealm(text: dataModel.weight,
                                             textFieldType: .weight,
                                             indexPath: indexPathToUse)

            didAddSet = false
            previousExerciseDetailInformation = ("", "")
        } else {
            let exercise = session.exercises[indexPathToUse.section]
            dataModel.reps = exercise.exerciseDetails[indexPathToUse.row].reps
            dataModel.weight = exercise.exerciseDetails[indexPathToUse.row].weight
        }
        exerciseDetailCell.configure(dataModel: dataModel)
        exerciseDetailCell.exerciseDetailCellDelegate = self
        return exerciseDetailCell
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        view.endEditing(true)

        let exercisesViewController = ExercisesViewController()
        exercisesViewController.presentationStyle = .modal
        exercisesViewController.exercisesDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: exercisesViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.transitioningDelegate = self
        navigationController?.present(modalNavigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CreateEditSessionTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        session.exercises.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        session.exercises[section].sets + 2
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.row {
        case 0: // Exercise header cell
            cell = getExerciseHeaderTableViewCell(for: indexPath)
        case tableView.numberOfRows(inSection: indexPath.section) - 1: // Add set cell
            cell = getButtonTableViewCell(for: indexPath)
        default: // Exercise detail cell
            cell = getExerciseDetailTableViewCell(for: indexPath)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        // Protecting the first, second, and last rows because they shouldn't be swipe to delete
        case 0, tableView.numberOfRows(inSection: indexPath.section) - 1:
            return false
        case 1:
            return session.exercises[indexPath.section].sets > 1
        default:
            return true
        }
    }

    //swiftlint:disable:next line_length
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Calls text field and text view didEndEditing() and saves data
        view.endEditing(true)
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, completion in
            Haptic.sendImpactFeedback(.medium)
            if self?.sessionState == .create {
                self?.removeSet(indexPath: indexPath)
            } else {
                try? self?.realm?.write {
                    self?.removeSet(indexPath: indexPath)
                }
            }

            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
                // Reloading section so the set indices can update
                tableView.reloadSections([indexPath.section], with: .automatic)
            })
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private func removeSet(indexPath: IndexPath) {
        session.exercises[indexPath.section].sets -= 1
        session.exercises[indexPath.section].exerciseDetails.remove(at: indexPath.row - 1)
    }
}

// MARK: - UITableViewDelegate
extension CreateEditSessionTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return Constants.exerciseHeaderCellHeight
        case tableView.numberOfRows(inSection: indexPath.section) - 1:
            return Constants.buttonCellHeight
        default:
            return Constants.exerciseDetailCellHeight
        }
    }
}

// MARK: - ExerciseHeaderCellDelegate
extension CreateEditSessionTableViewController: ExerciseHeaderCellDelegate {
    func deleteButtonTapped(cell: ExerciseHeaderTableViewCell) {
        Haptic.sendImpactFeedback(.medium)
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        if sessionState == .create {
            session.exercises.remove(at: section)
        } else {
            try? realm?.write {
                session.exercises.remove(at: section)
            }
        }
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }

    func weightButtonTapped(cell: ExerciseHeaderTableViewCell) {
        Haptic.sendSelectionFeedback()
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        if sessionState == .create {
            session.exercises[indexPath.section].weightType = cell.weightType
        } else {
            try? realm?.write {
                session.exercises[indexPath.section].weightType = cell.weightType
            }
        }
    }

    func doneButtonTapped(cell: ExerciseHeaderTableViewCell) {
        // No op
    }
}

// MARK: - ExerciseDetailTableViewCellDelegate
extension CreateEditSessionTableViewController: ExerciseDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 5
    }

    func textFieldDidEndEditing(textField: UITextField,
                                textFieldType: TextFieldType, cell: ExerciseDetailTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let indexPathToUse = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        saveTextFieldsWithOrWithoutRealm(text: textField.text,
                                         textFieldType: textFieldType, indexPath: indexPathToUse)
    }

    private func saveTextFieldsWithOrWithoutRealm(text: String?,
                                                  textFieldType: TextFieldType,
                                                  indexPath: IndexPath) {
        let text = text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise header cell
        if sessionState == .create {
            saveTextFieldData(text, textFieldType: textFieldType, indexPath: indexPath)
        } else {
            try? realm?.write {
                saveTextFieldData(text, textFieldType: textFieldType, indexPath: indexPath)
            }
        }
    }

    private func saveTextFieldData(_ text: String, textFieldType: TextFieldType, indexPath: IndexPath) {
        switch textFieldType {
        case .reps:
            session.exercises[indexPath.section].exerciseDetails[indexPath.row].reps = text
        case .weight:
            session.exercises[indexPath.section].exerciseDetails[indexPath.row].weight = text
        }
    }
}

// MARK: - ButtonTableViewCellDelegate
extension CreateEditSessionTableViewController: ButtonTableViewCellDelegate {
    func buttonTapped(cell: ButtonTableViewCell) {
        Haptic.sendImpactFeedback(.medium)
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        if sessionState == .create {
            addSet(section: section)
        } else {
            try? realm?.write {
                addSet(section: section)
            }
        }

        didAddSet = true
        let numberOfRows = tableView.numberOfRows(inSection: section)
        let indexPath = IndexPath(row: numberOfRows - 2, section: section)
        if let exerciseDetailCell = tableView.cellForRow(at: indexPath) as? ExerciseDetailTableViewCell {
            let previousReps = exerciseDetailCell.reps
            let previousWeight = exerciseDetailCell.weight
            previousExerciseDetailInformation = (previousReps, previousWeight)

            /*
             - Saving info in previously filled out ExerciseDetailTableViewCell in case the data wasn't saved
             - Usually it's saved when the textField resigns first responder
             - But if the user adds a set and doesn't resign the reps or weight textField first,
             then the data has to be manually saved by calling saveTextFieldsWithOrWithoutRealm()
             */
            saveTextFieldsWithOrWithoutRealm(text: previousReps,
                                             textFieldType: .reps,
                                             indexPath: indexPath)
            saveTextFieldsWithOrWithoutRealm(text: previousWeight,
                                             textFieldType: .weight,
                                             indexPath: indexPath)
        }

        DispatchQueue.main.async { [weak self] in
            let sets = self?.session.exercises[section].sets ?? 0
            let lastIndexPath = IndexPath(row: sets, section: section)

            self?.tableView.insertRows(at: [lastIndexPath], with: .automatic)
            // Scrolling to addSetButton row
            self?.tableView.scrollToRow(
                at: IndexPath(row: sets + 1, section: section),
                at: .none,
                animated: true)
        }
    }

    private func addSet(section: Int) {
        session.exercises[section].sets += 1
        session.exercises[section].exerciseDetails.append(ExerciseDetails())
    }
}

// MARK: - ExercisesDelegate
extension CreateEditSessionTableViewController: ExercisesDelegate {
    func updateExercises(_ exercises: [Exercise]) {
        exercises.forEach {
            let newExercise = $0
            if sessionState == .create {
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

// MARK: - UIViewControllerTransitioningDelegate
extension CreateEditSessionTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(
            presentedViewController: presented,
            presenting: presenting)
        modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.8)
        return modalPresentationController
    }
}

// MARK: - CustomTextViewDelegate
extension CreateEditSessionTableViewController: CustomTextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        tableView.performBatchUpdates({
            textView.sizeToFit()
        })
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == Constants.dimmedBlack {
            textView.text.removeAll()
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            let name = session.name
            let info = session.info
            let textInfo = [name, info]

            if let text = textInfo[textView.tag] {
                textView.text = text
                textView.textColor = .black
            } else {
                textView.text = textView.tag == 0 ?
                    Constants.namePlaceholderText : Constants.infoPlaceholderText
                textView.textColor = Constants.dimmedBlack
            }
            return
        }
    }
}

// MARK: - KeyboardObserving
extension CreateEditSessionTableViewController: KeyboardObserving {
    // Using didShow and didHide to prevent tableHeaderView flickering on keyboard dismissal
    func keyboardDidShow(_ notification: Notification) {
        guard let navigationController = navigationController,
            let keyboardHeight = notification.keyboardSize?.height else {
            return
        }

        let offset = abs(navigationController.view.frame.height - keyboardHeight - tableView.frame.maxY)
        tableView.contentInset.bottom = offset
    }

    func keyboardDidHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}
