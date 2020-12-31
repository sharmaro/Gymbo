//
//  StartSessionTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/21/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class StartSessionTVC: UITableViewController {
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

    private lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(didPan))
    }()

    private var realm: Realm? {
        try? Realm()
    }

    private var initialPanViewFrame: CGRect?
    private var panState = PanState.full

    var initialTabBarFrame: CGRect?
    weak var dimmedView: UIView?
    weak var panView: UIView?

    var customDataSource: StartSessionTVDS?
    var customDelegate: StartSessionTVD?
    var startSessionTimers: StartSessionTimers?
    var exercisesTVDS: ExercisesTVDS?

    deinit {
        startSessionTimers?.invalidateAll()
    }
}

// MARK: - Structs/Enums
private extension StartSessionTVC {
    struct Constants {
        static let timeInterval = TimeInterval(1)

        static let tableFooterViewHeight = CGFloat(120)
        static let defaultYOffset = CGFloat(60)

        static let barButtonSize = CGSize(width: 80, height: 30)
    }

    enum PanState {
        case full
        case mini
    }
}

// MARK: - UIViewController Var/Funcs
extension StartSessionTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
        addConstraints()
        loadData()
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
extension StartSessionTVC: ViewAdding {
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

        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.register(ExerciseHeaderTVCell.self,
                           forCellReuseIdentifier: ExerciseHeaderTVCell.reuseIdentifier)
        tableView.register(ExerciseDetailTVCell.self,
                           forCellReuseIdentifier: ExerciseDetailTVCell.reuseIdentifier)
        tableView.register(ButtonTVCell.self,
                           forCellReuseIdentifier: ButtonTVCell.reuseIdentifier)

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
extension StartSessionTVC {
    private func loadData() {
        customDataSource?.loadData()
        startSessionTimers?.loadData()
    }

    private func setupTableHeaderView() {
        let dataModel = customDataSource?
            .sessionHeaderViewModel() ?? SessionHeaderViewModel()
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

    private func cleanupProperties() {
        dimmedView?.removeFromSuperview()
        panView?.removeFromSuperview()
        customDataSource?.session = nil
        initialTabBarFrame = nil
        startSessionTimers?.invalidateAll()
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
                guard let mainTBC = navigationController?.mainTBC else {
                    return
                }

                let tabBarHeight = mainTBC.tabBar.frame.height
                let newLocation = mainTBC.view.frame.height -
                    tabBarHeight - minimizedHeight + location.y
                if newLocation <= mainTBC.view.frame.height -
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
            dimmedView?.frame.origin = mainTBC?.view.frame.origin ?? .zero
        }

        UIView.animate(withDuration: .defaultAnimationTime,
                       animations: { [weak self] in
            guard let panFrame = self?.initialPanViewFrame,
                let mainTBC = self?.navigationController?.mainTBC else {
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
            mainTBC.tabBar.frame.origin = CGPoint(x: 0,
                                                  y: mainTBC.view.frame.height)
        }) { [weak self] _ in
            self?.panState = .full
        }
    }

    private func resizeToMiniView() {
        UIView.animate(withDuration: .defaultAnimationTime,
                       animations: { [weak self] in
            guard let defaultTabBarFrame = self?.initialTabBarFrame,
                let mainTBC = self?.navigationController?.mainTBC else {
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

            let mainTBCHeight = mainTBC.view.frame.height
            let tabBarHeight = defaultTabBarFrame.height
            let minimizedHeight = self?.minimizedHeight ?? 0
            let newYPosition = mainTBCHeight - tabBarHeight - minimizedHeight

            self?.panView?.frame.origin = CGPoint(x: 0, y: newYPosition)
            mainTBC.tabBar.frame = defaultTabBarFrame
        }) { [weak self] _ in
            if self?.panState != .mini {
                self?.dimmedView?.frame.origin = self?.panView?.frame.origin ?? CGPoint.zero
            }
            self?.panState = .mini
        }
    }

    @objc private func restButtonTapped() {
        guard let startSessionTimers = startSessionTimers else {
            return
        }
        Haptic.sendSelectionFeedback()

        customDataSource?.modallyPresenting = .restVC
        let restVC = VCFactory.makeRestVC(startSessionTimers: startSessionTimers)
        let modalNC = VCFactory.makeMainNC(rootVC: restVC,
                                           transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)
    }

    @objc private func finishButtonTapped() {
        Haptic.sendImpactFeedback(.heavy)
        let rightButtonAction = { [weak self] in
            Haptic.sendImpactFeedback(.heavy)
            self?.customDataSource?.setLastExerciseDetail()
            DispatchQueue.main.async {
                self?.dismissAsChildViewController(endType: .finish)
            }
        }
        let alertData = AlertData(title: "Finish Session",
                                  content: "Do you want to finish the session?",
                                  leftButtonTitle: "No",
                                  rightButtonTitle: "Yes",
                                  rightButtonAction: rightButtonAction)
        presentCustomAlert(alertData: alertData)
    }

    @objc func dismissAsChildViewController(endType: EndType) {
        customDataSource?.removeStartedSession()
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
            navigationController.mainTBC?.tabBar.frame = defaultTabBarFrame
        }) { [weak self] (finished) in
            if finished {
                self?.customDataSource?.sessionDidEnd(endType: endType)
                self?.cleanupProperties()
                self?.childDismissal()
            }
        }
    }
}

// MARK: StartedSessionTimerDelegate
extension StartSessionTVC: StartedSessionTimerDelegate {
    func sessionSecondsUpdated() {
        let sessionSeconds = startSessionTimers?.sessionSeconds ?? 0
        title = sessionSeconds.minutesAndSecondsString
    }

    func restTimeRemainingUpdated() {
        guard let startSessionTimers = startSessionTimers else {
            return
        }
        timerButton.title = startSessionTimers.restTimeRemaining > 0 ?
            startSessionTimers.restTimeRemaining.minutesAndSecondsString :
            0.minutesAndSecondsString
        timerButton.addMovingLayerAnimation(duration: startSessionTimers.restTimeRemaining,
                                            totalTime: startSessionTimers.totalRestTime,
                                            timeRemaining: startSessionTimers.restTimeRemaining)
    }

    func restTimerStarted() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: timerButton)
        timerButton.addMovingLayerAnimation(
            duration: startSessionTimers?.restTimeRemaining ?? 0)
    }

    func resumeRestTimer() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: timerButton)
    }

    func totalRestTimeUpdated() {
        let totalRestTime = startSessionTimers?.totalRestTime ?? 0
        let restTimeRemaining = startSessionTimers?.restTimeRemaining ?? 0
        timerButton.addMovingLayerAnimation(duration: restTimeRemaining,
                                            totalTime: totalRestTime,
                                            timeRemaining: restTimeRemaining)
    }

    func restTimerEnded() {
        timerButton.removeMovingLayerAnimation()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Rest",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(restButtonTapped))

        // In case this timer finishes first.
        presentedViewController?.dismiss(animated: true)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension StartSessionTVC: UIGestureRecognizerDelegate {
    // Preventing panGesture eating up table view gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer != panGesture
    }
}
