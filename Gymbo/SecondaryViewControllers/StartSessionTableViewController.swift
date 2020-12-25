//
//  StartSessionTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/21/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
class StartSessionTableViewController: UITableViewController {
    private let timerButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.barButtonSize))
        button.titleLabel?.font = .small
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private let finishButton: CustomButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.barButtonSize))
        button.title = "Finish"
        button.titleLabel?.font = .small
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private let tableHeaderView = SessionHeaderView()
    private var didLayoutTableHeaderView = false

    var session: Session?
    weak var sessionProgresssDelegate: SessionProgressDelegate?

    var initialTabBarFrame: CGRect?
    weak var dimmedView: UIView?
    weak var panView: UIView?
    private lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(didPan))
    }()
    private var initialPanViewFrame: CGRect?
    private var panState = PanState.full

    private var modallyPresenting = ModallyPresenting.none

    private var sessionSeconds = 0 {
        didSet {
            title = sessionSeconds.minutesAndSecondsString
        }
    }
    private var sessionTimer: Timer?

    private var restTimer: Timer?
    private var totalRestTime = 0
    private var restTimeRemaining = 0 {
        didSet {
            timerButton.title = restTimeRemaining > 0 ?
            restTimeRemaining.minutesAndSecondsString : 0.minutesAndSecondsString
        }
    }

    private var realm: Realm? {
        try? Realm()
    }

    private var selectedRows = Set<IndexPath>()
    private let userDefault = UserDefaults.standard

    weak var updateDelegate: UpdateDelegate?

    deinit {
        sessionTimer?.invalidate()
        restTimer?.invalidate()
    }
}

// MARK: - Structs/Enums
private extension StartSessionTableViewController {
    struct Constants {
        static let timeInterval = TimeInterval(1)

        static let characterLimit = 5

        static let exerciseHeaderCellHeight = CGFloat(59)
        static let exerciseDetailCellHeight = CGFloat(40)
        static let buttonCellHeight = CGFloat(65)
        static let tableFooterViewHeight = CGFloat(120)
        static let defaultYOffset = CGFloat(60)

        static let barButtonSize = CGSize(width: 80, height: 30)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
        static let buttonText = "+ Set"

        static let SESSION_SECONDS_KEY = "sessionSeconds"
        static let REST_TOTAL_TIME_KEY = "restTotalTime"
        static let REST_REMAINING_TIME_KEY = "restRemainingTime"
    }

    enum PanState {
        case full
        case mini
    }

    enum ModallyPresenting {
        case restViewController
        case exercisesTableViewController
        case none
    }
}

// MARK: - UIViewController Var/Funcs
extension StartSessionTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
        addConstraints()
        resumeSessionIfNecessary()
        registerForKeyboardNotifications()
        registerForApplicationStateNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        panView?.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        initialPanViewFrame = panView?.frame
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.post(name: .updateSessionsUI, object: nil)
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
extension StartSessionTableViewController: ViewAdding {
    func setupNavigationBar() {
        title = 0.minutesAndSecondsString

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Rest",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(restButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: finishButton)

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        timerButton.addTarget(self, action: #selector(restButtonTapped), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)

        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.register(ExerciseHeaderTableViewCell.self,
                           forCellReuseIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier)
        tableView.register(ExerciseDetailTableViewCell.self,
                           forCellReuseIdentifier: ExerciseDetailTableViewCell.reuseIdentifier)
        tableView.register(ButtonTableViewCell.self,
                           forCellReuseIdentifier: ButtonTableViewCell.reuseIdentifier)

        setupTableHeaderView()
        setupTableFooterView()
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
extension StartSessionTableViewController {
    private func setupTableHeaderView() {
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .dynamicBlack

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = false
    }

    private func setupTableFooterView() {
        let footerViewFrame = CGRect(origin: .zero,
                                     size: CGSize(width: tableView.frame.width,
                                                  height: Constants.tableFooterViewHeight))
        let tableFooterView = StartSessionFooterView(frame: footerViewFrame)
        tableFooterView.startSessionButtonDelegate = self
        tableView.tableFooterView = tableFooterView
        tableView.tableFooterView = tableView.tableFooterView
    }

    private func startSessionTimer() {
        sessionTimer = Timer.scheduledTimer(timeInterval: Constants.timeInterval,
                                            target: self,
                                            selector: #selector(updateSessionTime),
                                            userInfo: nil,
                                            repeats: true)
        if let timer = sessionTimer {
            // Allows it to update the navigation bar.
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func startRestTimer() {
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(timeInterval: Constants.timeInterval,
                                         target: self,
                                         selector: #selector(updateRestTime),
                                         userInfo: nil,
                                         repeats: true)
        if let timer = restTimer {
            // Allows it to update in the navigation bar.
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func cleanupProperties() {
        dimmedView?.removeFromSuperview()
        panView?.removeFromSuperview()
        session = nil
        initialTabBarFrame = nil
        sessionTimer?.invalidate()
        restTimer?.invalidate()
    }

    private func childDismissal() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        navigationController?.willMove(toParent: nil)
        navigationController?.view.removeFromSuperview()
        navigationController?.removeFromParent()
    }

    //swiftlint:disable:next cyclomatic_complexity
    @objc private func didPan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view,
            let panFrame = initialPanViewFrame else {
            return
        }

        let location = gestureRecognizer.translation(in: view)

        switch gestureRecognizer.state {
        case .changed:
            let offset = location.y + Constants.defaultYOffset

            switch panState {
            case .full:
                if offset >= panFrame.origin.y && offset <= view.frame.height - minimizedHeight {
                    view.frame.origin.y = offset
                }
            case .mini:
                guard let mainTabBarController = navigationController?.mainTabBarController else {
                    return
                }

                let tabBarHeight = mainTabBarController.tabBar.frame.height
                let newLocation = mainTabBarController.view.frame.height -
                    tabBarHeight - minimizedHeight + location.y
                if newLocation <= mainTabBarController.view.frame.height -
                    tabBarHeight -
                    minimizedHeight && newLocation >= Constants.defaultYOffset {
                    view.frame.origin.y = newLocation
                }
            }
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: view)
            let maxPresentedY = (panFrame.height - Constants.defaultYOffset) / 2

            if panState == .full && velocity.y > 600 {
                resizeToMiniView()
            } else if panState == .mini && velocity.y < -600 {
                resizeToFullView()
            } else {
                if view.frame.origin.y < maxPresentedY {
                    resizeToFullView()
                } else {
                    resizeToMiniView()
                }
            }
        default:
            break
        }
    }

    private func resizeToFullView() {
        if panState != .full {
            dimmedView?.frame.origin = mainTabBarController?.view.frame.origin ?? .zero
        }

        UIView.animate(withDuration: .defaultAnimationTime,
                       animations: { [weak self] in
            guard let panFrame = self?.initialPanViewFrame,
                let mainTabBarController = self?.navigationController?.mainTabBarController else {
                return
            }

            /*
             Making sure this doesn't get called when the view is panned down a little bit and released,
             yielding in an unnecessary call
            */
            if self?.panState != .full {
                self?.dimmedView?.backgroundColor = .dimmedBackgroundBlack
                self?.panView?.hideShadow()
            }
            self?.navigationController?.navigationBar.prefersLargeTitles = true
            self?.panView?.frame = panFrame
            mainTabBarController.tabBar.frame.origin = CGPoint(x: 0,
                                                               y: mainTabBarController.view.frame.height)
        }) { [weak self] _ in
            self?.panState = .full
        }
    }

    private func resizeToMiniView() {
        UIView.animate(withDuration: .defaultAnimationTime,
                       animations: { [weak self] in
            guard let defaultTabBarFrame = self?.initialTabBarFrame,
                let mainTabBarController = self?.navigationController?.mainTabBarController else {
                return
            }

            /*
             Making sure this doesn't get called when the view is panned down a little bit and released,
             yielding in an unnecessary call
            */
            if self?.panState != .mini {
                self?.dimmedView?.backgroundColor = .clear
                self?.panView?.showShadow()
            }
            self?.navigationController?.navigationBar.prefersLargeTitles = false

            let mainTabBarControllerHeight = mainTabBarController.view.frame.height
            let tabBarHeight = defaultTabBarFrame.height
            let minimizedHeight = self?.minimizedHeight ?? 0
            let newYPosition = mainTabBarControllerHeight - tabBarHeight - minimizedHeight

            self?.panView?.frame.origin = CGPoint(x: 0, y: newYPosition)
            mainTabBarController.tabBar.frame = defaultTabBarFrame
        }) { [weak self] _ in
            if self?.panState != .mini {
                self?.dimmedView?.frame.origin = self?.panView?.frame.origin ?? CGPoint.zero
            }
            self?.panState = .mini
        }
    }

    private func getExerciseHeaderTableViewCell(for indexPath: IndexPath,
                                                session: Session) -> ExerciseHeaderTableViewCell {
        guard let exerciseHeaderTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseHeaderTableViewCell.reuseIdentifier,
            for: indexPath) as? ExerciseHeaderTableViewCell else {
            fatalError("Could not dequeue \(ExerciseHeaderTableViewCell.reuseIdentifier)")
        }

        var dataModel = ExerciseHeaderTableViewCellModel()
        dataModel.name = session.exercises[indexPath.section].name
        dataModel.weightType = session.exercises[indexPath.section].weightType
        dataModel.isDoneButtonImageHidden = false

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

    private func getExerciseDetailTableViewCell(for indexPath: IndexPath,
                                                session: Session) -> ExerciseDetailTableViewCell {
        guard let exerciseDetailCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseDetailTableViewCell.reuseIdentifier,
            for: indexPath) as? ExerciseDetailTableViewCell else {
            fatalError("Could not dequeue \(ExerciseDetailTableViewCell.reuseIdentifier)")
        }

        let exercise = session.exercises[indexPath.section]
        var dataModel = ExerciseDetailTableViewCellModel()

        dataModel.sets = "\(indexPath.row)"
        dataModel.last = exercise.exerciseDetails[indexPath.row - 1].last ?? "--"
        dataModel.reps = exercise.exerciseDetails[indexPath.row - 1].reps
        dataModel.weight = exercise.exerciseDetails[indexPath.row - 1].weight
        dataModel.isDoneButtonEnabled = true

        exerciseDetailCell.configure(dataModel: dataModel)
        exerciseDetailCell.exerciseDetailCellDelegate = self
        exerciseDetailCell.didSelect = selectedRows.contains(indexPath)
        return exerciseDetailCell
    }

    @objc private func restButtonTapped() {
        Haptic.sendSelectionFeedback()
        modallyPresenting = .restViewController

        let restViewController = RestViewController()
        restViewController.isTimerActive = restTimer?.isValid ?? false
        restViewController.startSessionTotalRestTime = totalRestTime
        restViewController.startSessionRestTimeRemaining = restTimeRemaining
        restViewController.restTimerDelegate = self

        updateDelegate = restViewController

        let modalNavigationController = UINavigationController(rootViewController: restViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.transitioningDelegate = self
        navigationController?.present(modalNavigationController, animated: true)
    }

    @objc private func finishButtonTapped() {
        Haptic.sendImpactFeedback(.heavy)
        let rightButtonAction = { [weak self] in
            Haptic.sendImpactFeedback(.heavy)
            if let session = self?.session {
                for exercise in session.exercises {
                    for detail in exercise.exerciseDetails {
                        let weight = Utility.formattedString(
                            stringToFormat: detail.weight,
                            type: .weight)
                        let reps = detail.reps ?? "--"
                        let last: String
                        if weight != "--" && reps != "--" {
                            last = "\(reps) x \(weight)"
                        } else {
                            last = "--"
                        }
                        try? self?.realm?.write {
                            detail.last = last
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                self?.dismissAsChildViewController()
            }
        }
        let alertData = AlertData(title: "Finish Session",
                                  content: "Do you want to finish the session?",
                                  leftButtonTitle: "No",
                                  rightButtonTitle: "Yes",
                                  rightButtonAction: rightButtonAction)
        presentCustomAlert(alertData: alertData)
    }

    @objc private func updateSessionTime() {
        sessionSeconds += 1
    }

    @objc private func updateRestTime() {
        restTimeRemaining -= 1
        updateDelegate?.update()

        if restTimeRemaining == 0 {
            Haptic.sendNotificationFeedback(.success)
            ended()
        }
    }

    @objc func dismissAsChildViewController() {
        if let startedSession = realm?.objects(StartedSession.self).first {
            try? realm?.write {
                realm?.delete(startedSession)
            }
        }

        UIView.animate(withDuration: .defaultAnimationTime, animations: { [weak self] in
            guard let navigationController = self?.navigationController,
                let defaultTabBarFrame = self?.initialTabBarFrame else {
                return
            }

            self?.dimmedView?.alpha = 0

            navigationController.view.frame = CGRect(
                origin: CGPoint(x: 0,
                                y: navigationController.view.frame.height),
                size: navigationController.view.frame.size)
            navigationController.mainTabBarController?.tabBar.frame = defaultTabBarFrame
        }) { [weak self] (finished) in
            if finished {
                self?.sessionProgresssDelegate?.sessionDidEnd(self?.session)
                self?.cleanupProperties()
                self?.childDismissal()
            }
        }
    }

    private func resumeSessionIfNecessary() {
        if let startedSession = realm?.objects(StartedSession.self).first {
            selectedRows.removeAll()
            let selectedRowsList = startedSession.selectedRows
            for row in selectedRowsList {
                selectedRows.insert(row.indexPath)
            }
            resumeSessionTimer()
        } else {
            startSessionTimer()
        }
    }

    private func resumeSessionTimer() {
        if let date = userDefault.object(forKey: UserDefaultKeys.STARTSESSION_DATE) as? Date,
            let timeDictionary = userDefault.object(
                forKey: UserDefaultKeys.STARTSESSION_TIME_DICTIONARY) as? [String: Int],
            let sessionSeconds = timeDictionary[Constants.SESSION_SECONDS_KEY] {

            let secondsElapsed = Int(Date().timeIntervalSince(date))

            self.sessionSeconds = sessionSeconds
            self.sessionSeconds += secondsElapsed
            startSessionTimer()

            let restTotalTime = timeDictionary[Constants.REST_TOTAL_TIME_KEY] ?? 0
            let restRemainingTime = timeDictionary[Constants.REST_REMAINING_TIME_KEY] ?? 0
            let newTimeRemaining = restRemainingTime - secondsElapsed

            if newTimeRemaining > 0 {
                totalRestTime = restTotalTime
                restTimeRemaining = newTimeRemaining
                navigationItem.leftBarButtonItem = UIBarButtonItem(customView: timerButton)
                timerButton.addMovingLayerAnimation(duration: restTimeRemaining,
                                                    totalTime: totalRestTime,
                                                    timeRemaining: restTimeRemaining)

                startRestTimer()
            } else {
                timerButton.removeMovingLayerAnimation()
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Rest",
                                                                   style: .plain,
                                                                   target: self,
                                                                   action: #selector(restButtonTapped))
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension StartSessionTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let session = session else {
            let alertData = AlertData(content: "Could not start session.",
                                      usesBothButtons: false,
                                      rightButtonTitle: "Sounds good")
            presentCustomAlert(alertData: alertData)
            return 0
        }
        return session.exercises.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let session = session else {
            let alertData = AlertData(content: "Could not start session.",
                                      usesBothButtons: false,
                                      rightButtonTitle: "Sounds good")
            presentCustomAlert(alertData: alertData)
            return 0
        }

        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        return session.exercises[section].sets + 2
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let session = session else {
            fatalError("Session is nil in \(String(describing: self))")
        }

        let cell: UITableViewCell
        switch indexPath.row {
        case 0: // Exercise header cell
            cell = getExerciseHeaderTableViewCell(for: indexPath, session: session)
        case tableView.numberOfRows(inSection: indexPath.section) - 1: // Add set cell
            cell = getButtonTableViewCell(for: indexPath)
        default: // Exercise detail cell
            cell = getExerciseDetailTableViewCell(for: indexPath, session: session)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        // Protecting the first, second, and last rows because they shouldn't be swipe to delete
        case 0, tableView.numberOfRows(inSection: indexPath.section) - 1:
            return false
        case 1:
            return (session?.exercises[indexPath.section].sets ?? 0) > 1
        default:
            return true
        }
    }

    //swiftlint:disable:next line_length
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, completion in
            Haptic.sendImpactFeedback(.medium)
            try? self?.realm?.write {
                self?.removeSet(indexPath: indexPath)
            }
            self?.selectedRows.remove(indexPath)

            let rowsInSection = tableView.numberOfRows(inSection: indexPath.section)
            let indexToStartAt = indexPath.row + 1
            if indexToStartAt < rowsInSection {
                for i in indexToStartAt..<rowsInSection {
                    let currentIndexPath = IndexPath(row: i, section: indexPath.section)
                    let newIndexPath = IndexPath(row: i - 1, section: indexPath.section)

                    self?.selectedRows.remove(currentIndexPath)
                    self?.selectedRows.insert(newIndexPath)
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
        guard let session = session else {
            return
        }

        session.exercises[indexPath.section].sets -= 1
        session.exercises[indexPath.section].exerciseDetails.remove(at: indexPath.row - 1)
    }
}

// MARK: - UITableViewDelegate
extension StartSessionTableViewController {
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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
        tableView.deselectRow(at: indexPath, animated: false)

        guard let exerciseDetailCell = tableView.cellForRow(
            at: indexPath) as? ExerciseDetailTableViewCell else {
            return
        }

        let containsIndexPath = selectedRows.contains(indexPath)
        if containsIndexPath {
            selectedRows.remove(indexPath)
        } else {
            selectedRows.insert(indexPath)
        }
        exerciseDetailCell.didSelect = !containsIndexPath
    }
}

// MARK: - ExerciseHeaderCellDelegate
extension StartSessionTableViewController: ExerciseHeaderCellDelegate {
    func deleteButtonTapped(cell: ExerciseHeaderTableViewCell) {
        Haptic.sendImpactFeedback(.medium)
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        try? realm?.write {
            session?.exercises.remove(at: section)
        }
        tableView.deleteSections(IndexSet(integer: section), with: .automatic)
        // Update SessionsCollectionViewController
        NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
    }

    func weightButtonTapped(cell: ExerciseHeaderTableViewCell) {
        Haptic.sendSelectionFeedback()
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        try? realm?.write {
            session?.exercises[indexPath.section].weightType = cell.weightType
        }
    }

    func doneButtonTapped(cell: ExerciseHeaderTableViewCell) {
        Haptic.sendImpactFeedback(.medium)
        guard let section = tableView.indexPath(for: cell)?.section else {
            return
        }

        let rows = tableView.numberOfRows(inSection: section)
        for i in 0..<rows {
            let indexPath = IndexPath(row: i, section: section)
            if let cell = tableView.cellForRow(at: indexPath) as? ExerciseDetailTableViewCell {
                selectedRows.insert(indexPath)
                cell.didSelect = true
            }
        }
    }
}

// MARK: - ExerciseDetailTableViewCellDelegate
extension StartSessionTableViewController: ExerciseDetailTableViewCellDelegate {
    func shouldChangeCharactersInTextField(textField: UITextField, replacementString string: String) -> Bool {
        let totalString = "\(textField.text ?? "")\(string)"
        return totalString.count <= Constants.characterLimit // Need a constant for this
    }

    func textFieldDidEndEditing(textField: UITextField,
                                textFieldType: TextFieldType,
                                cell: ExerciseDetailTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            NSLog("Found nil index path for text field after it ended editing.")
            return
        }

        let text = textField.text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise header cell
        try? realm?.write {
            saveTextFieldData(text,
                              textFieldType: textFieldType,
                              section: indexPath.section,
                              row: indexPath.row - 1)
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

// MARK: - ButtonTableViewCellDelegate
extension StartSessionTableViewController: ButtonTableViewCellDelegate {
    func buttonTapped(cell: ButtonTableViewCell) {
        Haptic.sendImpactFeedback(.medium)
        guard let section = tableView.indexPath(for: cell)?.section,
              let session = session else {
            return
        }

        try? realm?.write {
            addSet(section: section)
        }

        DispatchQueue.main.async { [weak self] in
            let sets = session.exercises[section].sets
            let lastIndexPath = IndexPath(row: sets, section: section)

            // Using .none because the animation doesn't work well with this VC
            self?.tableView.insertRows(at: [lastIndexPath], with: .none)
            // Scrolling to addSetButton row
            self?.tableView.scrollToRow(at: IndexPath(row: sets + 1,
                                                      section: section),
                                        at: .none,
                                        animated: true)
        }
    }

    private func addSet(section: Int) {
        session?.exercises[section].sets += 1
        session?.exercises[section].exerciseDetails.append(ExerciseDetails())
    }
}

// MARK: - ExercisesDelegate
extension StartSessionTableViewController: ExercisesDelegate {
    func updateExercises(_ exercises: [Exercise]) {
        exercises.forEach {
            let newExercise = $0
            try? realm?.write {
                session?.exercises.append(newExercise)
            }
        }
        tableView.reloadWithoutAnimation()
        // Update SessionsCollectionViewController
        NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
    }
}

// MARK: - StartSessionButtonDelegate
extension StartSessionTableViewController: StartSessionButtonDelegate {
    func addExercise() {
        modallyPresenting = .exercisesTableViewController

        let exercisesTableViewController = ExercisesTableViewController(style: .grouped)
        exercisesTableViewController.presentationStyle = .modal
        exercisesTableViewController.exercisesDelegate = self

        let modalNavigationController = UINavigationController(rootViewController:
                                                                exercisesTableViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.transitioningDelegate = self
        navigationController?.present(modalNavigationController, animated: true)
    }

    func cancelSession() {
        Haptic.sendImpactFeedback(.heavy)
        let rightButtonAction = { [weak self] in
            Haptic.sendImpactFeedback(.heavy)
            DispatchQueue.main.async {
                self?.dismissAsChildViewController()
            }
        }
        let alertData = AlertData(title: "Cancel Session",
                                  content: "Do you want to cancel the session?",
                                  leftButtonTitle: "No",
                                  rightButtonTitle: "Yes",
                                  rightButtonAction: rightButtonAction)
        presentCustomAlert(alertData: alertData)
    }
}

// MARK: - RestTimerDelegate
extension StartSessionTableViewController: RestTimerDelegate {
    func started(totalTime: Int) {
        totalRestTime = totalTime
        restTimeRemaining = totalRestTime
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: timerButton)
        timerButton.addMovingLayerAnimation(duration: restTimeRemaining)

        startRestTimer()
    }

    func timeUpdated(totalTime: Int, timeRemaining: Int) {
        totalRestTime = totalTime
        restTimeRemaining = timeRemaining

        timerButton.addMovingLayerAnimation(duration: restTimeRemaining,
                                            totalTime: totalRestTime,
                                            timeRemaining: restTimeRemaining)
    }

    func ended() {
        restTimer?.invalidate()
        timerButton.removeMovingLayerAnimation()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Rest",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(restButtonTapped))

        // In case this timer finishes first.
        presentedViewController?.dismiss(animated: true)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension StartSessionTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(
            presentedViewController: presented,
            presenting: presenting)

        switch modallyPresenting {
        case .restViewController:
            modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.7)
        case .exercisesTableViewController:
            modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.8)
        case .none:
            break
        }
        return modalPresentationController
    }
}

// MARK: - KeyboardObserving
extension StartSessionTableViewController: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = notification.keyboardSize?.height,
              tableView.numberOfSections > 0 else {
            return
        }
        tableView.contentInset.bottom = keyboardHeight
    }

    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}

// MARK: - ApplicationStateObserving
extension StartSessionTableViewController: ApplicationStateObserving {
    func didEnterBackground(_ notification: Notification) {
        sessionTimer?.invalidate()
        restTimer?.invalidate()

        let timeDictionary: [String: Int] = [
            Constants.SESSION_SECONDS_KEY: sessionSeconds,
            Constants.REST_TOTAL_TIME_KEY: totalRestTime,
            Constants.REST_REMAINING_TIME_KEY: restTimeRemaining
        ]

        userDefault.set(Date(), forKey: UserDefaultKeys.STARTSESSION_DATE)
        userDefault.set(timeDictionary, forKey: UserDefaultKeys.STARTSESSION_TIME_DICTIONARY)

        if let session = session {
            let selectedRowsList = List<RealmIndexPath>()
            let convertedObjects = selectedRows.map { RealmIndexPath(indexPath: $0) }
            selectedRowsList.append(objectsIn: convertedObjects)
            let updatedStartedSession = StartedSession(name: session.name,
                                                info: session.info,
                                                selectedRows: selectedRowsList,
                                                exercises: session.exercises)

            if let startedSession = realm?.objects(StartedSession.self).first {
                try? realm?.write {
                    realm?.delete(startedSession)
                    realm?.add(updatedStartedSession)
                }
            } else {
                try? realm?.write {
                    realm?.add(updatedStartedSession)
                }
            }
        }
    }

    func willEnterForeground(_ notification: Notification) {
        resumeSessionTimer()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension StartSessionTableViewController: UIGestureRecognizerDelegate {
    // Preventing panGesture eating up table view gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer != panGesture
    }
}
