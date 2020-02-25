//
//  ExercisesViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/11/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ExerciseListDelegate: class {
    func updateExerciseList(_ exerciseTextList: [ExerciseText])
}

// Codable is for encoding/decoding
struct ExerciseText: Codable {
    var exerciseName: String?
    var exerciseMuscles: String?
    let isUserMade: Bool
}

class ExercisesViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var searchTextField: SearchTextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addExerciseButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private var selectedExerciseNamesAndIndexPaths = [String: IndexPath]()
    private var selectedExerciseNames = [String]()
    private var exerciseDataModel = ExerciseDataModel.shared

    var state = State.onlyRightBarButton

    weak var exerciseListDelegate: ExerciseListDelegate?
}

// MARK: - Structs/Enums
extension ExercisesViewController {
    private struct Constants {
        static let exerciseCellHeight = CGFloat(62)
        static let headerHeight = CGFloat(30)
        static let headerFontSize = CGFloat(20)
    }

    enum State {
        case noBarButtons
        case onlyRightBarButton
        case bothBarButtons
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSearchTextField()
        setupTableView()
        setupAddExerciseButton()
        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        exerciseDataModel.removeSearchedResults()
    }
}

// MARK: - Funcs
extension ExercisesViewController {
    private func setupNavigationBar() {
        title = state == .onlyRightBarButton ? "My Exercises" : "Add Exercises"

        switch state {
        case .noBarButtons:
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
        case .onlyRightBarButton:
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createExerciseButtonTapped))
        case .bothBarButtons:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createExerciseButtonTapped))
        }
    }

    private func setupSearchTextField() {
        searchTextField.searchTextFieldDelegate = self
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        tableView.register(ExerciseTableViewCell.nib,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)

        if state == .onlyRightBarButton {
            addExerciseButton.removeFromSuperview()
            NSLayoutConstraint.activate([
                tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }

    private func setupAddExerciseButton() {
        addExerciseButton.title = "Add"
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.add(backgroundColor: .systemBlue)
        addExerciseButton.addCorner()
        addExerciseButton.makeUninteractable()
    }

    private func saveExerciseInfo() {
        // Get exercise info from the selected exercises
        guard selectedExerciseNamesAndIndexPaths.count > 0 else {
            return
        }

        var indexPaths = [IndexPath]()
        for exercise in selectedExerciseNames {
            if let indexPathToAppend = selectedExerciseNamesAndIndexPaths[exercise] {
                indexPaths.append(indexPathToAppend)
            }
        }

        var selectedExercises = [ExerciseText]()
        for indexPath in indexPaths {
            guard let group = exerciseDataModel.exerciseGroup(for: indexPath.section) else {
                break
            }
            let exerciseText = exerciseDataModel.exerciseText(for: group, for: indexPath.row)
            selectedExercises.append(exerciseText)
        }
        exerciseListDelegate?.updateExerciseList(selectedExercises)
    }

    private func updateAddButtonTitle() {
        var title = ""
        let isEnabled: Bool


        if selectedExerciseNames.count > 0 {
            title = "Add (\(selectedExerciseNames.count))"
            isEnabled = true
        } else {
            title = "Add"
            isEnabled = false
        }
        isEnabled ? addExerciseButton.makeInteractable() : addExerciseButton.makeUninteractable()
        addExerciseButton.title = title
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func createExerciseButtonTapped() {
        let createExerciseViewController = CreateExerciseViewController.loadFromXib()
        createExerciseViewController.createExerciseDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: createExerciseViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.transitioningDelegate = self
        present(modalNavigationController, animated: true, completion: nil)
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        let exercisesCount = selectedExerciseNamesAndIndexPaths.count
        let exerciseText =  exercisesCount > 1 ? "\(exercisesCount) exercises" : "1 exercise"
        presentCustomAlert(content: "Add \(exerciseText) to current session?") { [weak self] in
            self?.saveExerciseInfo()
            if self?.state == .noBarButtons {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ExercisesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return exerciseDataModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell,
            let group = exerciseDataModel.exerciseGroup(for: indexPath.section) else {
            fatalError("Could not dequeue cell with identifier `\(ExerciseTableViewCell.reuseIdentifier)`.")
        }

        let exerciseTableViewCellModel = exerciseDataModel.exerciseTableViewCellModel(for: group, for: indexPath.row)
        cell.configure(dataModel: exerciseTableViewCellModel)
        if state == .bothBarButtons || state == .noBarButtons {
            handleCellSelection(cell: cell, model: exerciseTableViewCellModel, indexPath: indexPath)
        }
        return cell
    }

    private func handleCellSelection(cell: UITableViewCell, model: ExerciseText, indexPath: IndexPath) {
        if let exerciseCell = cell as? ExerciseTableViewCell {
            if let exerciseName = model.exerciseName,
                selectedExerciseNamesAndIndexPaths.count > 0, selectedExerciseNamesAndIndexPaths[exerciseName] != nil {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                exerciseCell.didSelect = true
            } else {
                exerciseCell.didSelect = false
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard state == .onlyRightBarButton,
            let group = exerciseDataModel.exerciseGroup(for: indexPath.section) else {
            return false
        }

        let exerciseTableViewCellModel = exerciseDataModel.exerciseTableViewCellModel(for: group, for: indexPath.row)
        return exerciseTableViewCellModel.isUserMade
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
            let exerciseName = exerciseCell.exerciseName,
            let trueIndexPath = exerciseDataModel.indexPath(from: indexPath.section, exerciseName: exerciseName) else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_, completion in
            self?.exerciseDataModel.removeExercise(at: trueIndexPath)
            DispatchQueue.main.async {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}

// MARK: - UITableViewDelegate
extension ExercisesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let exerciseGroup = exerciseDataModel.exerciseGroup(for: section) else {
            fatalError("exerciseDataModel.exerciseGroup is nil ")
        }
        let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: Constants.headerHeight)))
        containerView.backgroundColor = tableView.numberOfRows(inSection: section) > 0 ? .black : .darkGray

        let titleLabel = UILabel()
        titleLabel.text = exerciseGroup
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: Constants.headerFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        titleLabel.leadingAndTrailingTo(superView: containerView, leading: 10, trailing: 0)

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.exerciseCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard state != .onlyRightBarButton,
            let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
            let exerciseName = exerciseCell.exerciseName,
            let trueIndexPath = exerciseDataModel.indexPath(from: indexPath.section, exerciseName: exerciseName) else {
            return
        }

        selectedExerciseNamesAndIndexPaths[exerciseName] = trueIndexPath
        selectedExerciseNames.append(exerciseName)
        exerciseCell.didSelect = true
        updateAddButtonTitle()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard state != .onlyRightBarButton,
            let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
            let exerciseName = exerciseCell.exerciseName else {
            return
        }

        selectedExerciseNamesAndIndexPaths[exerciseName] = nil
        for (index, value) in selectedExerciseNames.enumerated() {
            if value == exerciseName {
                selectedExerciseNames.remove(at: index)
                break
            }
        }
        exerciseCell.didSelect = false
        updateAddButtonTitle()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            searchTextField.frame.origin.y = -scrollView.contentOffset.y
        }
    }
}

// MARK: - CreateExerciseDelegate
extension ExercisesViewController: CreateExerciseDelegate {
    func addCreatedExercise(exerciseGroup: String, exerciseText: ExerciseText) {
        exerciseDataModel.addCreatedExercise(exerciseGroup: exerciseGroup, exerciseText: exerciseText)
        tableView.reloadData()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ExercisesViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.4)
        return modalPresentationController
    }
}

// MARK: - SearchTextFieldDelegate
extension ExercisesViewController: SearchTextFieldDelegate {
    func textFieldDidChange(_ textField: UITextField) {
        guard let filter = textField.text?.lowercased(),
            filter.count > 0 else {
                exerciseDataModel.removeSearchedResults()
                tableView.reloadData()
                return
        }

        exerciseDataModel.filterResults(filter: filter)
        tableView.reloadData()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

// MARK: - KeyboardObserving
extension ExercisesViewController: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = notification.keyboardSize?.height else {
            return
        }

        tableView.contentInset.bottom = keyboardHeight
    }

    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}
