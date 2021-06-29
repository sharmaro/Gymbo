//
//  MainTBC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class MainTBC: UITabBarController {
    var isSessionInProgress = false

    private var isReplacingSession = false
    private var sessionToReplace: Session?

    private var realm: Realm? {
        try? Realm()
    }

    var customDataSource: MainTBDS?

    init(customDataSource: MainTBDS?) {
        self.customDataSource = customDataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
extension MainTBC {
    private enum Constants {
        static let defaultYOffset = CGFloat(60)
    }

    enum SessionState {
        case start
        case end
    }
}

// MARK: - UITabBarController Var/Funcs
extension MainTBC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showOnboardingIfNeeded()
        resumeStartedSession()
    }
}

// MARK: - Funcs
extension MainTBC {
    private func setupTabBar() {
        delegate = customDataSource

        tabBar.backgroundColor = .primaryBackground
        tabBar.barTintColor = .primaryBackground
        // Color of selected item
        tabBar.unselectedItemTintColor = .secondaryText
        // Prevents tab bar color from being lighter than intended
        tabBar.backgroundImage = UIImage()

        guard let customDataSource = customDataSource else {
            fatalError("custom data source not set up for MainTBC")
        }
        viewControllers = customDataSource.viewControllers
        selectedIndex = customDataSource.selectedTab.rawValue
    }

    private func showOnboardingIfNeeded() {
        if customDataSource?.user?.isFirstTimeLoad ?? true {
            let onboardingVC = VCFactory.makeOnboardingVC(
                user: customDataSource?.user)
            present(onboardingVC, animated: true)
        }
    }

    private func updateSessionProgressObservingViewControllers(state: SessionState,
                                                               endType: EndType = .cancel) {
        viewControllers?.forEach {
            if let rootVC = ($0 as? MainNC)?.rootVC as? SessionProgressDelegate {
                switch state {
                case .start:
                    rootVC.sessionDidStart(nil)
                case .end:
                    rootVC.sessionDidEnd(nil, endType: endType)
                }
            }
        }
    }

    private func startSession(_ session: Session?) {
        isSessionInProgress = true
        updateSessionProgressObservingViewControllers(state: .start)

        let blurredView = VisualEffectView(frame: view.frame,
                                           style: .dark)

        let height = view.frame.height - Constants.defaultYOffset
        let shadowContainerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height),
                                                       size: CGSize(width: view.frame.width,
                                                                    height: height)))
        shadowContainerView.addShadow(direction: .up)
        shadowContainerView.hideShadow()

        let exercisesTVDS = customDataSource?.exercisesTVDS
        let startedSessionTVC = VCFactory.makeStartedSessionTVC(style: .grouped,
                                                                session: session,
                                                                exercisesTVDS: exercisesTVDS,
                                                                delegate: self,
                                                                blurredView: blurredView,
                                                                panView: shadowContainerView,
                                                                initialTabBarFrame: tabBar.frame)

        let containerNavigationController = MainNC(rootVC: startedSessionTVC)
        containerNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        containerNavigationController.view.addCorner(style: .small)

        shadowContainerView.addSubview(containerNavigationController.view)
        containerNavigationController.view.autoPinSafeEdges(to: shadowContainerView)

        view.insertSubview(shadowContainerView, belowSubview: tabBar)
        addChild(containerNavigationController)
        containerNavigationController.didMove(toParent: self)

        view.insertSubview(blurredView, belowSubview: shadowContainerView)
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.4,
                       delay: 0.1,
                       animations: { [weak self] in
            guard let self = self else { return }

            shadowContainerView.frame.origin = CGPoint(x: 0, y: Constants.defaultYOffset)
            self.tabBar.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        })

        if sessionToReplace != nil {
            sessionToReplace = nil
        }
    }

    private func resumeStartedSession() {
        guard let startedSession = realm?.objects(StartedSession.self).first else {
            return
        }

        let sessionToStart = Session(name: startedSession.name,
                                     info: startedSession.info,
                                     exercises: startedSession.exercises)
        startSession(sessionToStart)
    }
}

// MARK: - SessionProgressDelegate
extension MainTBC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        if isSessionInProgress {
            guard let startedSessionTVC = (children.last as? MainNC)?
                    .rootVC as? StartedSessionTVC else {
                return
            }

            let alertData = AlertData(title: "Another One?",
                                      content: "You already have a workout in progress!",
                                      usesBothButtons: true,
                                      leftButtonTitle: "I'll finish this one!",
                                      rightButtonTitle: "Start New Workout",
                                      rightButtonAction: { [weak self] in
                                        self?.isReplacingSession = true
                                        self?.sessionToReplace = session

                                        DispatchQueue.main.async {
                                            startedSessionTVC.dismissAsChildViewController(
                                                endType: .cancel)
                                        }
                                      })
            presentCustomAlert(alertData: alertData)
        } else {
            startSession(session)
        }
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        guard let session = session else {
            return
        }

        isSessionInProgress = false
        customDataSource?.user?.addSession(session: session, endType: endType)

        if isReplacingSession, sessionToReplace != nil {
            isReplacingSession = false
            startSession(sessionToReplace)
        } else {
            updateSessionProgressObservingViewControllers(state: .end,
                                                          endType: endType)
        }
    }
}
