//
//  MainTBC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit
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
    private struct Constants {
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

        tabBar.backgroundColor = .dynamicWhite
        tabBar.barTintColor = .dynamicWhite
        // Color of selected item
        tabBar.unselectedItemTintColor = .dynamicDarkTabItem
        // Prevents tab bar color from being lighter than intended
        tabBar.backgroundImage = UIImage()

        guard let customDataSource = customDataSource else {
            fatalError("custom data source not set up for MainTBC")
        }
        viewControllers = customDataSource.viewControllers
        selectedIndex = customDataSource.selectedTab.rawValue
    }

    private func showOnboardingIfNeeded() {
        if UserDataModel.shared.isFirstTimeLoad {
            let onboardingVC = VCFactory.makeOnboardingVC()
            present(onboardingVC, animated: true)
        }
    }

    private func updateSessionProgressObservingViewControllers(state: SessionState,
                                                               endType: EndType = .cancel) {
        viewControllers?.forEach {
            if let viewControllers = ($0 as? UINavigationController)?.viewControllers,
               let viewController = viewControllers.first as? SessionProgressDelegate {
                switch state {
                case .start:
                    viewController.sessionDidStart(nil)
                case .end:
                    viewController.sessionDidEnd(nil, endType: endType)
                }
            }
        }
    }

    private func startSession(_ session: Session?) {
        isSessionInProgress = true
        updateSessionProgressObservingViewControllers(state: .start)

        let dimmedView = UIView(frame: view.frame)
        dimmedView.backgroundColor = .dimmedBackgroundBlack

        let height = view.frame.height - Constants.defaultYOffset
        let shadowContainerView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: view.frame.height),
                                                       size: CGSize(width: view.frame.width,
                                                                    height: height)))
        shadowContainerView.addShadow(direction: .up)
        shadowContainerView.hideShadow()

        let startSessionTVC = StartSessionTVC()
        startSessionTVC.session = session
        startSessionTVC.sessionProgresssDelegate = self
        startSessionTVC.dimmedView = dimmedView
        startSessionTVC.panView = shadowContainerView
        startSessionTVC.initialTabBarFrame = tabBar.frame
        // This allows startSessionViewController to extend over the bottom tab bar
        startSessionTVC.extendedLayoutIncludesOpaqueBars = true

        let containerNavigationController = MainNC(rootVC: startSessionTVC)
        containerNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        containerNavigationController.view.addCorner(style: .small)

        shadowContainerView.addSubview(containerNavigationController.view)
        containerNavigationController.view.autoPinSafeEdges(to: shadowContainerView)

        view.insertSubview(shadowContainerView, belowSubview: tabBar)
        addChild(containerNavigationController)
        containerNavigationController.didMove(toParent: self)

        view.insertSubview(dimmedView, belowSubview: shadowContainerView)
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

    private func saveCompletedSessionData(session: Session?, endType: EndType) {
        guard let session = session else {
            return
        }

        switch endType {
        case .cancel:
            try? realm?.write {
                UserDataModel.shared.user?
                    .canceledExercises.append(objectsIn: session.exercises)
            }
        case .finish:
            try? realm?.write {
                UserDataModel.shared.user?
                    .finishedExercises.append(objectsIn: session.exercises)
            }
        }
    }
}

// MARK: - SessionProgressDelegate
extension MainTBC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        if isSessionInProgress {
            guard let navigationController = (children.last as? UINavigationController),
                  let startSessionTVC = navigationController
                    .viewControllers.first as? StartSessionTVC else {
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
                                            startSessionTVC.dismissAsChildViewController(
                                                endType: .cancel)
                                        }
                                      })
            presentCustomAlert(alertData: alertData)
        } else {
            startSession(session)
        }
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        isSessionInProgress = false

        saveCompletedSessionData(session: session,
                                 endType: endType)

        if isReplacingSession, sessionToReplace != nil {
            isReplacingSession = false
            startSession(sessionToReplace)
        } else {
            updateSessionProgressObservingViewControllers(state: .end,
                                                          endType: endType)
        }
    }
}
