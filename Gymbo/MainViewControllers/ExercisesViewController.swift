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
    var name: String?
    var muscles: String?
    let isUserMade: Bool
}

// MARK: - Properties
class ExercisesViewController: UIViewController {
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var addExerciseButton: CustomButton = {
        let customButton = CustomButton(frame: .zero)
        customButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)
        customButton.translatesAutoresizingMaskIntoConstraints = false
        return customButton
    }()
    private var addExerciseButtonBottomConstraint: NSLayoutConstraint?
    private var didViewAppear = false

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
        static let sessionStartedConstraintConstant = CGFloat(-50)
        static let sessionEndedConstraintConstant = CGFloat(-15)
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisesViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupNavigationBar()
        addMainViews()
        setupTableView()
        setupAddExerciseButton()
        registerForKeyboardNotifications()
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
        searchController.searchBar.placeholder = "Search for an exercise"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    private func addMainViews() {
        view.addSubviews(views: [tableView, addExerciseButton])
    }

    private func setupTableView() {
        NSLayoutConstraint.activate([
            // Using top anchor instead of safe area to get smooth navigation title size change animation
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        tableView.register(ExerciseTableViewCell.self,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)
    }

    private func setupAddExerciseButton() {
        NSLayoutConstraint.activate([
            addExerciseButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 15),
            addExerciseButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addExerciseButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant:  -20),
            addExerciseButton.heightAnchor.constraint(equalToConstant: 45)
        ])
        addExerciseButtonBottomConstraint = addExerciseButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.sessionEndedConstraintConstant)
        addExerciseButtonBottomConstraint?.isActive = true

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

        let createExerciseViewController = CreateExerciseViewController()
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

    @objc private func addExerciseButtonTapped(_ sender: UIButton) {
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
            if let exerciseName = model.name,
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
        titleLabel.font = .systemFont(ofSize: Constants.headerFontSize)
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
