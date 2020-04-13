//
//  ExercisesViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/11/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol SetAlphaDelegate: class {
    func setAlpha(alpha: CGFloat)
}

protocol ExerciseListDelegate: class {
    func updateExerciseList(_ exerciseTextList: [ExerciseText])
}

enum PresentationStyle {
    case normal
    case modal
}

// Codable is for encoding/decoding
struct ExerciseText: Codable {
    var exerciseName: String?
    var exerciseMuscles: String?
    let isUserMade: Bool
}

// MARK: - Properties
class ExercisesViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var addExerciseButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private var selectedExerciseNamesAndIndexPaths = [String: IndexPath]()
    private var selectedExerciseNames = [String]()
    private var exerciseDataModel = ExerciseDataModel.shared

    var presentationStyle = PresentationStyle.normal

    weak var exerciseListDelegate: ExerciseListDelegate?
}

// MARK: - Structs/Enums
extension ExercisesViewController {
    private struct Constants {
        static let exerciseCellHeight = CGFloat(62)
        static let headerHeight = CGFloat(30)
        static let headerFontSize = CGFloat(20)
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupTableView()
        setupAddExerciseButton()
        registerForKeyboardNotifications()
        registerForSessionProgressNotifications()
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
        title = presentationStyle == .normal ? "My Exercises" : "Add Exercises"

        switch presentationStyle {
        case .normal:
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createExerciseButtonTapped))
        case .modal:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createExerciseButtonTapped))
        }

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Exercise"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
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
        navigationController?.dismiss(animated: true)
    }

    @objc private func createExerciseButtonTapped() {
        view.endEditing(true)

        let createExerciseViewController = CreateExerciseViewController.loadFromXib()
        createExerciseViewController.createExerciseDelegate = self
        createExerciseViewController.setAlphaDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: createExerciseViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.modalTransitionStyle = .crossDissolve
        modalNavigationController.transitioningDelegate = self
        navigationController?.present(modalNavigationController, animated: true)

        if presentationStyle == .modal {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.navigationController?.view.alpha = 0
            })
        }
    }

    @IBAction func addExerciseButton(_ sender: Any) {
        saveExerciseInfo()
        dismiss(animated: true)
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
                presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
                return UITableViewCell()
        }

        let exerciseTableViewCellModel = exerciseDataModel.exerciseTableViewCellModel(for: group, for: indexPath.row)
        cell.configure(dataModel: exerciseTableViewCellModel)
        if presentationStyle == .modal {
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
        guard presentationStyle == .normal,
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
            return nil
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
        guard presentationStyle != .normal,
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
        guard presentationStyle != .normal,
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
}

// MARK: - UISearchResultsUpdating
extension ExercisesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar

        guard let filter = searchBar.text?.lowercased(),
            filter.count > 0 else {
                exerciseDataModel.removeSearchedResults()
                tableView.reloadData()
                return
        }

        exerciseDataModel.filterResults(filter: filter)
        tableView.reloadData()
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
        modalPresentationController.showDimmingView = presentationStyle == .normal
        modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.42)
        return modalPresentationController
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

// MARK: - SetAlphaDelegate
extension ExercisesViewController: SetAlphaDelegate {
    func setAlpha(alpha: CGFloat) {
        if presentationStyle == .modal {
            UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseIn, animations: { [weak self] in
                self?.navigationController?.view.alpha = alpha
            })
        }
    }
}

// MARK: - SessionProgressObserving
extension ExercisesViewController: SessionProgressObserving {
    func sessionDidStart(_ notification: Notification) {
        if mainTabBarController?.isSessionInProgress ?? false {
            tableView.contentInset.bottom = minimizedHeight
        }
    }

    func sessionDidEnd(_ notification: Notification) {
        tableView.contentInset.bottom = 0
    }
}
