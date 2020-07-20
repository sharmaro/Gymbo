//
//  ExercisesViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/11/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisesViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = .white
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let addExerciseButton: CustomButton = {
        let button = CustomButton()
        button.title = "Add"
        button.titleLabel?.textAlignment = .center
        button.add(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        button.addShadow(direction: .down)
        button.makeUninteractable(animated: false)
        return button
    }()

    private var addExerciseButtonBottomConstraint: NSLayoutConstraint?

    private var didViewAppear = false

    private let exerciseDataModel = ExerciseDataModel.shared
    private var selectedExerciseNamesAndIndices = [String: Int]()
    private var selectedExerciseNames = [String]()

    var presentationStyle = PresentationStyle.normal

    weak var exercisesDelegate: ExercisesDelegate?
}

// MARK: - Structs/Enums
extension ExercisesViewController {
    private struct Constants {
        static let addExerciseButtonHeight = CGFloat(45)
        static let exerciseCellHeight = CGFloat(70)
        static let sessionStartedConstraintConstant = CGFloat(-64)
        static let sessionEndedConstraintConstant = CGFloat(-20)
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
        searchController.searchBar.placeholder = "Search exercises"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // Hides the active search bar if a new view controller is presented
        definesPresentationContext = true

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView])
        if presentationStyle == .modal {
            view.add(subviews: [addExerciseButton])
        }
    }

    func setupViews() {
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ExercisesHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHeaderFooterView.reuseIdentifier)
        tableView.register(ExerciseTableViewCell.self,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)

        if presentationStyle == .modal {
            addExerciseButton.isHidden = presentationStyle == .normal
            addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)

            let spacing = CGFloat(15)
            tableView.contentInset.bottom = Constants.addExerciseButtonHeight + (-1 * Constants.sessionEndedConstraintConstant) + spacing
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            // Using top anchor instead of safe area to get smooth navigation title size change animation
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        if presentationStyle == .modal {
            addExerciseButtonBottomConstraint = addExerciseButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.sessionEndedConstraintConstant)
            addExerciseButtonBottomConstraint?.isActive = true

            NSLayoutConstraint.activate([
                addExerciseButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                addExerciseButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -20),
                addExerciseButton.heightAnchor.constraint(equalToConstant: Constants.addExerciseButtonHeight)
            ])
        }
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
        showActivityIndicator(withText: "Loading Exercises")
        setupExerciseDataModel()
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
    private func setupExerciseDataModel() {
        exerciseDataModel.dataFetchDelegate = self
        exerciseDataModel.fetchData()
    }

    private func saveExercise() {
        // Get exercise info from the selected exercises
        guard !selectedExerciseNamesAndIndices.isEmpty else {
            return
        }

        var selectedExercises = [Exercise]()
        for exerciseName in selectedExerciseNames {
            // Need to create a new exercise object to be passed into selectedExercises so the existing exericse isn't updated in Realm
            let referenceExercise = exerciseDataModel.exercise(for: exerciseName)
            let exercise = Exercise(name: referenceExercise.name,
                                    groups: referenceExercise.groups,
                                    instructions: referenceExercise.instructions,
                                    tips: referenceExercise.tips,
                                    imagesData: referenceExercise.imagesData,
                                    isUserMade: referenceExercise.isUserMade,
                                    weightType: referenceExercise.weightType,
                                    sets: referenceExercise.sets,
                                    exerciseDetails: referenceExercise.exerciseDetails)
            selectedExercises.append(exercise)
        }
        exercisesDelegate?.updateExercises(selectedExercises)
    }

    private func updateAddButtonTitle() {
        var title = ""
        let isEnabled: Bool

        if selectedExerciseNames.isEmpty {
            title = "Add"
            isEnabled = false
        } else {
            title = "Add (\(selectedExerciseNames.count))"
            isEnabled = true
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
        createEditExerciseTableViewController.exerciseDataModelDelegate = self
        createEditExerciseTableViewController.setAlphaDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: createEditExerciseTableViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.modalTransitionStyle = .crossDissolve
        modalNavigationController.transitioningDelegate = self
        navigationController?.present(modalNavigationController, animated: true)

        if presentationStyle == .modal {
            UIView.animate(withDuration: .defaultAnimationTime,
                           delay: 0,
                           options: .curveEaseInOut,
                           animations: { [weak self] in
                self?.navigationController?.view.alpha = 0
            })
        }
    }

    @objc private func addExerciseButtonTapped(_ sender: Any) {
        Haptic.shared.sendImpactFeedback(.medium)
        saveExercise()
        dismiss(animated: true)
    }

    @objc private func updateExercisesUI() {
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ExercisesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        exerciseDataModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell else {
            fatalError("Could not dequeue \(ExerciseTableViewCell.reuseIdentifier)")
        }

        let exercise = exerciseDataModel.exercise(for: indexPath)
        cell.configure(dataModel: exercise)

        if presentationStyle == .modal {
            handleCellSelection(cell: cell, model: exercise, indexPath: indexPath)
        }
        return cell
    }

    private func handleCellSelection(cell: UITableViewCell, model: Exercise, indexPath: IndexPath) {
        if let exerciseCell = cell as? ExerciseTableViewCell {
            if let exerciseName = model.name,
                !selectedExerciseNamesAndIndices.isEmpty, selectedExerciseNamesAndIndices[exerciseName] != nil {
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

        let exerciseTableViewCellModel = exerciseDataModel.exercise(for: indexPath)
        return exerciseTableViewCellModel.isUserMade
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let exerciseCell = tableView.cellForRow(at: indexPath) as? ExerciseTableViewCell,
            let exerciseName = exerciseCell.exerciseName else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _,_, completion in
            SessionDataModel.shared.removeInstancesOfExercise(name: exerciseName)
            self?.exerciseDataModel.removeExercise(named: exerciseName)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            Haptic.shared.sendImpactFeedback(.medium)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return exerciseDataModel.sectionTitles
    }
}

// MARK: - UITableViewDelegate
extension ExercisesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return exerciseDataModel.heightForHeaderIn(section: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return exerciseDataModel.heightForHeaderIn(section: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ExercisesHeaderFooterView.reuseIdentifier) as? ExercisesHeaderFooterView else {
            return nil
        }

        let title = exerciseDataModel.titleForHeaderIn(section: section)
        headerView.configure(title: title)
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.exerciseCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.shared.sendSelectionFeedback()
        switch presentationStyle {
        case .normal:
            tableView.deselectRow(at: indexPath, animated: true)

            let exercise = exerciseDataModel.exercise(for: indexPath)
            let exercisePreviewViewController = ExercisePreviewViewController(exercise: exercise)
            let modalNavigationController = UINavigationController(rootViewController: exercisePreviewViewController)
            modalNavigationController.modalPresentationStyle = .custom
            modalNavigationController.transitioningDelegate = self
            mainTabBarController?.present(modalNavigationController, animated: true)
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
        Haptic.shared.sendSelectionFeedback()
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
            !filter.isEmpty else {
                exerciseDataModel.removeSearchedResults()
                tableView.reloadData()
                return
        }

        exerciseDataModel.filterResults(filter: filter)
        tableView.reloadData()
    }
}

// MARK: - ExerciseDataModelDelegate
extension ExercisesViewController: ExerciseDataModelDelegate {
    func create(_ exercise: Exercise, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {
        exerciseDataModel.create(exercise, success: { [weak self] in
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
            UIView.animate(withDuration: .defaultAnimationTime,
                           delay: .defaultAnimationTime,
                           options: .curveEaseIn,
                           animations: { [weak self] in
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
        guard presentationStyle == .modal,
            let mainTabBarController = mainTabBarController else {
            return
        }

        if mainTabBarController.isSessionInProgress {
            addExerciseButtonBottomConstraint?.constant = Constants.sessionStartedConstraintConstant
        } else {
            addExerciseButtonBottomConstraint?.constant = Constants.sessionEndedConstraintConstant
        }

        if didViewAppear {
            UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
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

// MARK: - DataFetchDelegate
extension ExercisesViewController: DataFetchDelegate {
    func didEndFetch() {
        tableView.reloadData()
        hideActivityIndicator()
    }
}
