//
//  StartSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/18/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

class StartSessionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    class var id: String {
        return String(describing: self)
    }

    var session: Session?

    private var seconds = 0
    private var minutes = 0
    private var timer: Timer?

    private let realm = try? Realm()

    private lazy var finishButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.title = "Finish"
        button.addColor(backgroundColor: .systemGreen)
        button.addCornerRadius()
        button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var tableFooterView: UIView = {
        let tableFooterViewSize = CGSize(width: tableView.bounds.width, height: 105)
        let containerView = UIView(frame: CGRect(origin: .zero, size: tableFooterViewSize))

        let addExerciseButton = CustomButton()
        addExerciseButton.setTitle("+ Exercise", for: .normal)
        addExerciseButton.addColor(backgroundColor: .systemBlue)
        addExerciseButton.addCornerRadius()
        addExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)
        containerView.addSubview(addExerciseButton)

        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            addExerciseButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            addExerciseButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            addExerciseButton.heightAnchor.constraint(equalToConstant: Constants.navBarButtonSize.height)
        ])

        let cancelButton = CustomButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addColor(backgroundColor: .systemRed)
        cancelButton.addCornerRadius()
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        containerView.addSubview(cancelButton)

        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: addExerciseButton.bottomAnchor, constant: 30),
            cancelButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: Constants.navBarButtonSize.height)
        ])

        return containerView
    }()

    private lazy var sessionTableHeaderView: SessionTableHeaderView = {
        let sessionTableHeaderView = SessionTableHeaderView()
        sessionTableHeaderView.nameTextView.text = session?.name ?? Constants.sessionNamePlaceholderText
        sessionTableHeaderView.infoTextView.text = session?.info ?? Constants.sessionInfoPlaceholderText
        sessionTableHeaderView.isContentEditable = false
        sessionTableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        return sessionTableHeaderView
    }()

    private struct Constants {
        static let timeInterval = TimeInterval(1)

        static let verticalStackSpacing = CGFloat(30)
        static let exerciseHeaderCellHeight = CGFloat(59)
        static let exerciseDetailCellHeight = CGFloat(32)
        static let addSetButtonCellHeight = CGFloat(50)

        static let navBarButtonSize = CGSize(width: 80, height: 30)

        static let sessionNamePlaceholderText = "Session name"
        static let sessionInfoPlaceholderText = "No Info"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "00:00"
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.prefersLargeTitles = false


        setupNavigationBar()
        setupTableView()
        setupTableHeaderView()
        setupTableFooterView()
//        startTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableFooterView?.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        timer?.invalidate()
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.isTranslucent = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Rest", style: .plain, target: self, action: #selector(restButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishButton)
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

    private func setupTableFooterView() {
        tableView.tableFooterView = tableFooterView
    }

    private func setupTableHeaderView() {
        tableView.tableHeaderView = sessionTableHeaderView

        NSLayoutConstraint.activate([
            sessionTableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            sessionTableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            sessionTableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20),
            sessionTableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: Constants.timeInterval, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    @objc func restButtonTapped() {
        // TO DO
        // Create a rest modal vc that shows a rest timer
    }

    @objc private func finishButtonTapped() {
        if let session = session {
            for exercise in session.exercises {
                for detail in exercise.exerciseDetails {
                    let weight = Util.formattedString(stringToFormat: detail.weight, type: .weight)
                    let reps = detail.reps ?? "--"
                    let last: String
                    if weight != "--" && reps != "--" {
                        last = "\(reps) x \(weight)"
                    } else {
                        last = "--"
                    }
                    try? realm?.write {
                        detail.last = last
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func addExerciseButtonTapped() {
        guard let addExerciseViewController = storyboard?.instantiateViewController(withIdentifier: AddExerciseViewController.id) as? AddExerciseViewController else {
            return
        }

        addExerciseViewController.exerciseListDelegate = self
        addExerciseViewController.hideBarButtonItems = true
        navigationController?.pushViewController(addExerciseViewController, animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func updateTime() {
        seconds += 1

        if seconds == 60 {
            seconds = 0
            minutes += 1
        }

        let secondsString = String(format: "%02d", seconds)
        let minutesString = String(format: "%02d", minutes)
        title = "\(minutesString):\(secondsString)"
    }
}

extension StartSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let session = session else {
            fatalError("Session is nil in start session vc numberOfSections()")
        }
        return session.exercises.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let session = session else {
            fatalError("Session is nil in start session vc numberOfRowsInSection()")
        }

        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        return session.exercises[section].sets + 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let session = session else {
            fatalError("Session is nil in start session vc cellForRowAt()")
        }
        
        switch indexPath.row {
        case 0: // Exercise header cell
            if let exerciseHeaderCell = tableView.dequeueReusableCell(withIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseHeaderTableViewCell {
                exerciseHeaderCell.exerciseNameLabel.text = session.exercises[indexPath.section].name
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
                exerciseDetailCell.lastLabel.text = session.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].last ?? "--"
                exerciseDetailCell.repsTextField.text = session.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].reps ?? ""
                exerciseDetailCell.weightTextField.text = session.exercises[indexPath.section].exerciseDetails[indexPath.row - 1].weight ?? ""
                exerciseDetailCell.exerciseDetailCellDelegate = self

                return exerciseDetailCell
            }
        }
        fatalError("Could not dequeue a valid cell for start session table view")
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
            try? realm?.write {
                removeSet(section: indexPath.section)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    private func removeSet(section: Int) {
        guard let session = session else {
            return
        }

        session.exercises[section].sets -= 1
        session.exercises[section].exerciseDetails.remove(at: section)
    }
}

// MARK: - UITableViewDelegate

extension StartSessionViewController: UITableViewDelegate {
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

// MARK: - ExerciseHeaderCellDelegate

extension StartSessionViewController: ExerciseHeaderCellDelegate {
    func deleteExerciseButtonTapped(cell: ExerciseHeaderTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        try? realm?.write {
            session?.exercises.remove(at: section)
        }
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }
}

// MARK: - ExerciseDetailTableViewCellDelegate

extension StartSessionViewController: ExerciseDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count < 6 // Need a constant for this
    }

    func textFieldDidEndEditing(textField: UITextField, textFieldType: TextFieldType, cell: ExerciseDetailTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let text = textField.text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise header cell
        try? realm?.write {
            saveTextFieldData(text, textFieldType: textFieldType, section: indexPath.section, row: indexPath.row - 1)
        }
    }

    private func saveTextFieldData(_ text: String, textFieldType: TextFieldType, section: Int, row: Int) {
        switch textFieldType {
        case .reps:
            session?.exercises[section].exerciseDetails[row].reps = text
        case .weight:
            session?.exercises[section].exerciseDetails[row].weight = text
        }
    }
}

// MARK: - AddSetTableViewCellDelegate

extension StartSessionViewController: AddSetTableViewCellDelegate {
    func addSetButtonTapped(cell: AddSetTableViewCell) {
        guard let section = tableView.indexPath(for: cell)?.section,
              let session = session else {
            return
        }

        try? realm?.write {
            addSet(section: section)
        }

        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
        let sets = session.exercises[section].sets
        tableView.scrollToRow(at: IndexPath(row: sets + 1, section: section), at: .none, animated: true)
    }

    private func addSet(section: Int) {
        session?.exercises[section].sets += 1
        session?.exercises[section].exerciseDetails.append(ExerciseDetails())
    }
}

extension StartSessionViewController: ExerciseListDelegate {
    func updateExerciseList(_ exerciseTextList: [ExerciseText]) {
        for exerciseText in exerciseTextList {
            let newExercise = Exercise(name: exerciseText.exerciseName, muscleGroups: exerciseText.exerciseMuscles, sets: 1, exerciseDetails: List<ExerciseDetails>())
            try? realm?.write {
                session?.exercises.append(newExercise)
            }
        }
        UIView.performWithoutAnimation {
            tableView.reloadData()
        }
    }
}
