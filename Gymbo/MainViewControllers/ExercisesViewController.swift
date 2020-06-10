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
    func updateExerciseList(_ exerciseTextList: [ExerciseInfo])
}

enum PresentationStyle {
    case normal
    case modal
}

// MARK: - Properties
class ExercisesViewController: UIViewController {
    private var tableView = UITableView(frame: .zero)
    private var addExerciseButton = CustomButton(frame: .zero)

    private var addExerciseButtonBottomConstraint: NSLayoutConstraint?
    private var didViewAppear = false

    private var selectedExerciseNamesAndIndices = [String: Int]()
    private var selectedExerciseNames = [String]()
    private var exerciseDataModel = ExerciseDataModel.shared

    var presentationStyle = PresentationStyle.normal

    weak var exerciseListDelegate: ExerciseListDelegate?
}

// MARK: - Structs/Enums
extension ExercisesViewController {
    private struct Constants {
        static let exerciseCellHeight = CGFloat(70)
        static let sessionStartedConstraintConstant = CGFloat(-50)
        static let sessionEndedConstraintConstant = CGFloat(-15)
    }
}

// MARK: - ViewAdding
extension ExercisesViewController: ViewAdding {
    func setupNavigationBar() {
        title = presentationStyle == .normal ? "My Exercises" : "Add Exercises"

        switch presentationStyle {
        case .normal: break
        case .modal:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createExerciseButtonTapped))

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search for an exercise"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView, addExerciseButton])
    }

    func setupViews() {
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        tableView.register(ExerciseTableViewCell.self,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)

        addExerciseButton.title = "Add"
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.add(backgroundColor: .systemBlue)
        addExerciseButton.addCorner(style: .small)
        addExerciseButton.makeUninteractable(animated: false)
        addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            // Using top anchor instead of safe area to get smooth navigation title size change animation
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        addExerciseButtonBottomConstraint = addExerciseButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.sessionEndedConstraintConstant)
        addExerciseButtonBottomConstraint?.isActive = true
        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            addExerciseButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addExerciseButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -20),
            addExerciseButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()
        registerForKeyboardNotifications()

        NotificationCenter.default.addObserver(self, selector: #selector(updateExercisesUI), name: .updateExercisesUI, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didViewAppear = true
        renewConstraints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        didViewAppear = false
        exerciseDataModel.removeSearchedResults()
    }
}

// MARK: - Funcs
extension ExercisesViewController {
    private func saveExerciseInfo() {
        // Get exercise info from the selected exercises
        guard selectedExerciseNamesAndIndices.count > 0 else {
            return
        }

        var indices = [Int]()
        for exercise in selectedExerciseNames {
            if let index = selectedExerciseNamesAndIndices[exercise] {
                indices.append(index)
            }
        }

        var selectedExercises = [ExerciseInfo]()
        for index in indices {
            let exerciseInfo = exerciseDataModel.exerciseInfo(for: index)
            selectedExercises.append(exerciseInfo)
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

        let createEditExerciseTableViewController = CreateEditExerciseTableViewController()
        createEditExerciseTableViewController.exerciseState = .create
        createEditExerciseTableViewController.createEditExerciseDelegate = self
        createEditExerciseTableViewController.setAlphaDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: createEditExerciseTableViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.modalTransitionStyle = .crossDissolve
        modalNavigationController.transitioningDelegate = self
        navigationController?.present(modalNavigationController, animated: true)

        if presentationStyle == .modal {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                self?.navigationController?.view.alpha = 0
            })
        }
    }

    @objc private func addExerciseButtonTapped(_ sender: UIButton) {
        saveExerciseInfo()
        dismiss(animated: true)
    }

    @objc private func updateExercisesUI() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ExercisesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell else {
                presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
                return UITableViewCell()
        }

        let exerciseInfo = exerciseDataModel.exerciseInfo(for: indexPath.row)
        cell.configure(dataModel: exerciseInfo)

        if presentationStyle == .modal {
            handleCellSelection(cell: cell, model: exerciseInfo, indexPath: indexPath)
        }
        return cell
    }

    private func handleCellSelection(cell: UITableViewCell, model: ExerciseInfo, indexPath: IndexPath) {
        if let exerciseCell = cell as? ExerciseTableViewCell {
            if let exerciseName = model.name,
                selectedExerciseNamesAndIndices.count > 0, selectedExerciseNamesAndIndices[exerciseName] != nil {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                exerciseCell.didSelect = true
            } else {
                exerciseCell.didSelect = false
            }
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard presentationStyle == .normal else {
            return false
        }

        let exerciseTableViewCellModel = exerciseDataModel.exerciseInfo(for: indexPath.row)
        return exerciseTableViewCellModel.isUserMade
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
            let exerciseName = exerciseCell.exerciseName,
            let index = exerciseDataModel.index(of: exerciseName) else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_, completion in
            self?.exerciseDataModel.removeExercise(at: index)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.exerciseCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch presentationStyle {
        case .normal:
            tableView.deselectRow(at: indexPath, animated: true)

            let exerciseInfo = exerciseDataModel.exerciseInfo(for: indexPath.row)
            let exercisePreviewViewController = ExercisePreviewViewController(exerciseInfo: exerciseInfo)
            exercisePreviewViewController.dimmedViewDelegate = self
            exercisePreviewViewController.modalPresentationStyle = .overCurrentContext
            exercisePreviewViewController.modalTransitionStyle = .crossDissolve
            navigationController?.present(exercisePreviewViewController, animated: true)

            addView()
        case .modal:
            guard let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
                let exerciseName = exerciseCell.exerciseName,
                let index = exerciseDataModel.index(of: exerciseName) else {
                return
            }

            selectedExerciseNamesAndIndices[exerciseName] = index
            selectedExerciseNames.append(exerciseName)
            exerciseCell.didSelect = true
            updateAddButtonTitle()
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard presentationStyle != .normal,
            let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
            let exerciseName = exerciseCell.exerciseName else {
            return
        }

        selectedExerciseNamesAndIndices[exerciseName] = nil
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
extension ExercisesViewController: CreateEditExerciseDelegate {
    func createExerciseInfo(_ info: ExerciseInfo, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {
        exerciseDataModel.createExerciseInfo(info, success: { [weak self] in
            DispatchQueue.main.async {
                success()
                self?.tableView.reloadData()
            }
        }, fail: fail)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ExercisesViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        modalPresentationController.showDimmingView = presentationStyle == .normal
        modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.7)
        return modalPresentationController
    }
}

// MARK: - KeyboardObserving
extension ExercisesViewController: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        guard let mainTabBarController = navigationController?.mainTabBarController,
            let keyboardHeight = notification.keyboardSize?.height else {
            return
        }

        let bottomInset = abs(mainTabBarController.view.frame.height - keyboardHeight - tableView.frame.maxY)
        tableView.contentInset.bottom = bottomInset
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

// MARK: - SessionProgressDelegate
extension ExercisesViewController: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?) {
        renewConstraints()
    }
}

// MARK: - SessionStateConstraintsUpdating
extension ExercisesViewController: SessionStateConstraintsUpdating {
    func renewConstraints() {
        guard let mainTabBarController = mainTabBarController else {
            return
        }

        if mainTabBarController.isSessionInProgress {
            addExerciseButtonBottomConstraint?.constant = Constants.sessionStartedConstraintConstant
        } else {
            addExerciseButtonBottomConstraint?.constant = Constants.sessionEndedConstraintConstant
        }

        if didViewAppear {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - DimmedViewDelegate
extension ExercisesViewController: DimmedViewDelegate {
    func addView() {
        navigationController?.view.addDimmedView(animated: true)
    }

    func removeView() {
        navigationController?.view.removeDimmedView(animated: true)
    }
}
