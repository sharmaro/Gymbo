//
//  CreateEditSessionTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/3/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
class CreateEditSessionTVC: UITableViewController {
    private let tableHeaderView = SessionHeaderView()
    private var didLayoutTableHeaderView = false

    private var realm: Realm? {
        try? Realm()
    }

    var customDataSource: CreateEditSessionTVDS?
    var customDelegate: CreateEditSessionTVD?
}

// MARK: - Structs/Enums
private extension CreateEditSessionTVC {
    struct Constants {
        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "Info"
    }
}

// MARK: - UIViewController Var/Funcs
extension CreateEditSessionTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
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

        // Calls text field and text view didEndEditing() to save data
        view.endEditing(true)
        customDataSource?.saveSession(name: sessionName, info: tableHeaderView.secondText)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        if !didLayoutTableHeaderView {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.tableHeaderView?.layoutIfNeeded()
                self.tableView.tableHeaderView = self.tableView.tableHeaderView
            }
        }
        didLayoutTableHeaderView = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension CreateEditSessionTVC: ViewAdding {
    func setupNavigationBar() {
        title = customDataSource?.sessionState.rawValue ?? ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addExerciseButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.separatorStyle = .none
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.register(ExerciseHeaderTVCell.self,
                           forCellReuseIdentifier: ExerciseHeaderTVCell.reuseIdentifier)
        tableView.register(ExerciseDetailTVCell.self,
                           forCellReuseIdentifier: ExerciseDetailTVCell.reuseIdentifier)
        tableView.register(ButtonTVCell.self,
                           forCellReuseIdentifier: ButtonTVCell.reuseIdentifier)

        if mainTBC?.isSessionInProgress ?? false {
            tableView.contentInset.bottom = minimizedHeight
        }

        let session = customDataSource?.session
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = customDataSource?.sessionState == .create ?
                             .dimmedDarkGray : .dynamicBlack

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = true
        tableHeaderView.customTextViewDelegate = self
    }

    func setupColors() {
        view.backgroundColor = .dynamicWhite
    }

    func addConstraints() {
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = tableHeaderView
        NSLayoutConstraint.activate([
            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor)
        ])
    }
}

// MARK: - Funcs
extension CreateEditSessionTVC {
    @objc private func addExerciseButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        view.endEditing(true)

        let exercisesTVC = ExercisesTVC(style: .grouped)
        exercisesTVC.presentationStyle = .modal
        exercisesTVC.exerciseUpdatingDelegate = self

        let modalNC = VCFactory.makeMainNC(rootVC: exercisesTVC,
                                           transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)
    }
}

// MARK: - ListDataSource
extension CreateEditSessionTVC: ListDataSource {
    func cellForRowAt(tvCell: UITableViewCell) {
        if let exerciseHeaderTVCell = tvCell as? ExerciseHeaderTVCell {
            exerciseHeaderTVCell.exerciseHeaderCellDelegate = self
        } else if let buttonTVCell = tvCell as? ButtonTVCell {
            buttonTVCell.buttonTVCellDelegate = self
        } else if let exerciseDetailTVCell = tvCell as? ExerciseDetailTVCell {
            exerciseDetailTVCell.exerciseTVCellDelegate = self
        }
    }
}

// MARK: - ListDelegate
extension CreateEditSessionTVC: ListDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfiguration indexPath: IndexPath) {
        view.endEditing(true)
        customDataSource?.deleteSetRealm(indexPath: indexPath)
    }
}

// MARK: - ExerciseHeaderCellDelegate
extension CreateEditSessionTVC: ExerciseHeaderCellDelegate {
    func deleteButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        customDataSource?.deleteExerciseRealm(at: section)
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
    }

    func weightButtonTapped(cell: ExerciseHeaderTVCell) {
        guard let index = tableView.indexPath(for: cell)?.section else {
            return
        }
        Haptic.sendSelectionFeedback()

        customDataSource?.updateExerciseWeightTypeRealm(at: index,
                                                        weightType: cell.weightType)
    }

    func doneButtonTapped(cell: ExerciseHeaderTVCell) {
        // No op
    }
}

// MARK: - ButtonTVCellDelegate
extension CreateEditSessionTVC: ButtonTVCellDelegate {
    func buttonTapped(cell: ButtonTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section,
              let customDataSource = customDataSource else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        customDataSource.addSetRealm(section: section)
        customDataSource.didAddSet = true
        let numberOfRows = tableView.numberOfRows(inSection: section)
        let indexPath = IndexPath(row: numberOfRows - 2, section: section)
        if let exerciseDetailCell = tableView.cellForRow(at: indexPath) as? ExerciseDetailTVCell {
            let previousReps = exerciseDetailCell.reps
            let previousWeight = exerciseDetailCell.weight
            customDataSource.previousExerciseDetailInformation = (previousReps,
                                                                  previousWeight)
            /*
             - Saving info in previously filled out ExerciseDetailTVCell in case the data wasn't saved
             - Usually it's saved when the textField resigns first responder
             - But if the user adds a set and doesn't resign the reps or weight textField first,
             then the data has to be manually saved by calling saveTextFieldsWithOrWithoutRealm()
             */
            customDataSource.saveTextFieldsWithOrWithoutRealm(text: previousReps,
                                                              textFieldType: .reps,
                                                              indexPath: indexPath)
            customDataSource.saveTextFieldsWithOrWithoutRealm(text: previousWeight,
                                                              textFieldType: .weight,
                                                              indexPath: indexPath)
        }

        DispatchQueue.main.async { [weak self] in
            let sets = customDataSource
                .session.exercises[section].sets
            let lastIndexPath = IndexPath(row: sets, section: section)

            self?.tableView.insertRows(at: [lastIndexPath], with: .automatic)
            // Scrolling to addSetButton row
            self?.tableView.scrollToRow(
                at: IndexPath(row: sets, section: section),
                at: .top,
                animated: true)
        }
        view.endEditing(true)
    }
}

// MARK: - ExerciseUpdatingDelegate
extension CreateEditSessionTVC: ExerciseUpdatingDelegate {
    func updateExercises(_ exercises: [Exercise]) {
        customDataSource?.addExercisesRealm(exercises: exercises)
        tableView.reloadData()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension CreateEditSessionTVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationC = ModalPresentationC(
            presentedViewController: presented,
            presenting: presenting)
        modalPresentationC.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.8)
        return modalPresentationC
    }
}

// MARK: - KeyboardObserving
extension CreateEditSessionTVC: KeyboardObserving {
    // Using didShow and didHide to prevent tableHeaderView flickering on keyboard dismissal
    func keyboardDidShow(_ notification: Notification) {
        guard let keyboardHeight = notification.keyboardSize?.height,
              tableView.numberOfSections > 0 else {
            return
        }
        tableView.contentInset.bottom = keyboardHeight
    }

    func keyboardDidHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}
