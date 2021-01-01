//
//  ExercisesTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/11/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class ExercisesTVC: UITableViewController {
    private let addExerciseButton: CustomButton = {
        let button = CustomButton()
        button.title = "Add"
        button.titleLabel?.textAlignment = .center
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        button.set(state: .disabled, animated: false)
        button.layer.zPosition = 1
        return button
    }()

    private var addExerciseButtonBottomConstraint: NSLayoutConstraint?

    private var didViewAppear = false

    private var presentationStyle: PresentationStyle {
        customDataSource?.presentationStyle ?? .normal
    }

    var customDataSource: ExercisesTVDS?
    var customDelegate: ExercisesTVD?
    var sessionsCVDS: SessionsCVDS?

    weak var exerciseUpdatingDelegate: ExerciseUpdatingDelegate?
}

// MARK: - Structs/Enums
private extension ExercisesTVC {
    struct Constants {
        static let addExerciseButtonHeight = CGFloat(45)
        static let sessionStartedConstraintConstant = CGFloat(-64)
        static let sessionEndedConstraintConstant = CGFloat(-20)
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisesTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
        registerForKeyboardNotifications()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateExercisesUI),
                                               name: .updateExercisesUI,
                                               object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didViewAppear = true
        renewConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        didViewAppear = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ExercisesTVC: ViewAdding {
    func setupNavigationBar() {
        title = presentationStyle == .normal ? "My Exercises" : "Add Exercises"

        switch presentationStyle {
        case .normal:
            break
        case .modal:
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                               target: self,
                                                               action: #selector(cancelButtonTapped))
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(createExerciseButtonTapped))

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search exercises"
        searchController.searchBar.returnKeyType = .done
        searchController.searchResultsUpdater = customDataSource
        searchController.obscuresBackgroundDuringPresentation = false

        navigationItem.searchController = searchController
        // Hides the active search bar if a new view controller is presented
        definesPresentationContext = true

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        if presentationStyle == .modal {
            view.add(subviews: [addExerciseButton])
        }
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.sectionFooterHeight = 0
        tableView.tableFooterView = UIView()
        tableView.register(ExercisesHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHeaderFooterView.reuseIdentifier)
        tableView.register(ExerciseTVCell.self,
                           forCellReuseIdentifier: ExerciseTVCell.reuseIdentifier)

        if presentationStyle == .modal {
            addExerciseButton.isHidden = presentationStyle == .normal
            addExerciseButton.addTarget(self, action: #selector(addExerciseButtonTapped), for: .touchUpInside)

            let spacing = CGFloat(15)
            tableView.contentInset.bottom =
                Constants.addExerciseButtonHeight +
                (-1 * Constants.sessionEndedConstraintConstant) +
                spacing
        }
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .dynamicWhite }
    }

    func addConstraints() {
        if presentationStyle == .modal {
            addExerciseButtonBottomConstraint = addExerciseButton.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Constants.sessionEndedConstraintConstant)
            addExerciseButtonBottomConstraint?.isActive = true

            NSLayoutConstraint.activate([
                addExerciseButton.safeAreaLayoutGuide.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20),
                addExerciseButton.safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20),
                addExerciseButton.heightAnchor.constraint(equalToConstant: Constants.addExerciseButtonHeight)
            ])
        }
    }
}

// MARK: - Funcs
extension ExercisesTVC {
    private func saveExercise() {
        // Get exercise info from the selected exercises
        guard let selectedExerciseNames = customDataSource?
                .selectedExerciseNames,
              !selectedExerciseNames.isEmpty,
              let customDataSource = customDataSource else {
            return
        }

        let selectedExercises = selectedExerciseNames.map {
            customDataSource.exercise(for: $0).safeCopy
        }
        exerciseUpdatingDelegate?.updateExercises(selectedExercises)
    }

    private func updateAddButtonTitle() {
        guard let selectedExerciseNames = customDataSource?
                .selectedExerciseNames else {
            return
        }

        let isEnabled = !selectedExerciseNames.isEmpty
        let title = isEnabled ? "Add (\(selectedExerciseNames.count))" :
                                "Add"
        let state = InteractionState.stateFromBool(isEnabled)

        addExerciseButton.set(state: state)
        addExerciseButton.title = title
    }

    private func renewConstraints() {
        guard isViewLoaded,
            let mainTBC = mainTBC else {
            return
        }

        if presentationStyle == .modal {
            if mainTBC.isSessionInProgress {
                addExerciseButtonBottomConstraint?.constant = Constants.sessionStartedConstraintConstant
            } else {
                addExerciseButtonBottomConstraint?.constant = Constants.sessionEndedConstraintConstant
            }
        } else {
            if mainTBC.isSessionInProgress {
                tableView.contentInset.bottom = minimizedHeight
            } else {
                tableView.contentInset.bottom = .zero
            }
        }

        if didViewAppear {
            UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }

    @objc private func cancelButtonTapped() {
        Haptic.sendSelectionFeedback()
        /*
         - Because the DS is reused
         - It's important to remove the last one when the VC is dismissed
         - so there's no retain cycle
         */
        customDataSource?.removeLastDS()
        navigationController?.dismiss(animated: true)
    }

    @objc private func createExerciseButtonTapped() {
        Haptic.sendSelectionFeedback()
        view.endEditing(true)

        let createEditExerciseTVC = VCFactory
            .makeCreateEditExerciseTVC(delegate: self)
        createEditExerciseTVC.setAlphaDelegate = self

        let modalNC = VCFactory.makeMainNC(rootVC: createEditExerciseTVC,
                                       transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)

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
        Haptic.sendImpactFeedback(.medium)
        saveExercise()
        navigationItem.searchController?.isActive = false
        dismiss(animated: true)
    }

    @objc private func updateExercisesUI() {
        tableView.reloadData()
    }
}

// MARK: - ListDataSource
extension ExercisesTVC: ListDataSource {
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - ListDelegate
extension ExercisesTVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let exercise = customDataSource?.exercise(for: indexPath),
              let exerciseName = exercise.name else {
            return
        }
        Haptic.sendSelectionFeedback()

        switch presentationStyle {
        case .normal:
            tableView.deselectRow(at: indexPath, animated: true)

            let exercisePreviewTVC = VCFactory.makeExercisePreviewTVC(exercise: exercise,
                                             exercisesTVDS: customDataSource)
            let modalNC = VCFactory.makeMainNC(rootVC: exercisePreviewTVC,
                                           transitioningDelegate: self)
            navigationController?.present(modalNC, animated: true)
        case .modal:
            customDataSource?.selectCell(exerciseName: exerciseName,
                                         in: tableView,
                                         indexPath: indexPath)
            updateAddButtonTitle()
        }
    }

    func didDeselectItem(at indexPath: IndexPath) {
        guard let exercise = customDataSource?.exercise(for: indexPath),
              let exerciseName = exercise.name else {
            return
        }
        Haptic.sendSelectionFeedback()

        customDataSource?.selectCell(exerciseName: exerciseName,
                                     in: tableView,
                                     indexPath: indexPath)
        updateAddButtonTitle()
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfiguration indexPath: IndexPath) {
        guard let exerciseName = customDataSource?
                .exercise(for: indexPath).name else {
            return
        }

        sessionsCVDS?.removeInstancesOfExercise(name: exerciseName)
        customDataSource?.removeExercise(named: exerciseName)
    }
}

// MARK: - SessionProgressDelegate
extension ExercisesTVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        renewConstraints()
    }
}
