//
//  MainTabBarController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class MainTabBarController: UITabBarController {
    var isSessionInProgress = false

    private var selectedTab = Tabs.sessions

    private var isReplacingSession = false
    private var startSessionViewController: StartSessionTableViewController?
    private var sessionToReplace: Session?
}

// MARK: - Structs/Enums
private extension MainTabBarController {
    struct Constants {
        static let defaultYOffset = CGFloat(60)
    }

    enum Tabs: Int {
        case profile = 0
        case exercises
        case sessions
        case stopwatch

        var title: String {
            let text: String
            switch self {
            case .profile:
                text = "Profile"
            case .exercises:
                text = "My Exercises"
            case .sessions:
                text = "Sessions"
            case .stopwatch:
                text = "Stopwatch"
            }
            return text
        }

        var image: UIImage {
            let imageName: String
            switch self {
            case .profile:
                imageName = "profile"
            case .exercises:
                imageName = "my_exercises"
            case .sessions:
                imageName = "dumbbell"
            case .stopwatch:
                imageName = "stopwatch"
            }
            return UIImage(named: imageName) ?? UIImage()
        }
    }

    enum SessionState {
        case start
        case end
    }
}

// MARK: - UITabBarController Var/Funcs
extension MainTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showOnboardingIfNeeded()
    }
}

// MARK: - Funcs
extension MainTabBarController {
    private func setupTabBar() {
        tabBar.backgroundColor = .dynamicWhite
        tabBar.barTintColor = .dynamicWhite
        // Color of selected item
        tabBar.tintColor = .dynamicDarkTabItem
        tabBar.unselectedItemTintColor = .dynamicLightTabItem
        // Prevents tab bar color from being lighter than intended
        tabBar.backgroundImage = UIImage()

        let profileViewController = ProfileViewController()
        let profileTab = Tabs.profile
        profileViewController.tabBarItem = UITabBarItem(title: profileTab.title,
                                                        image: profileTab.image,
                                                        tag: profileTab.rawValue)

        let exercisesTableViewController = ExercisesTableViewController(style: .grouped)
        let exercisesTab = Tabs.exercises
        exercisesTableViewController.tabBarItem = UITabBarItem(title: exercisesTab.title,
                                                          image: exercisesTab.image,
                                                          tag: exercisesTab.rawValue)

        // Need to initialize a UICollectionView with a UICollectionViewLayout
        let sessionsCollectionViewController = SessionsCollectionViewController(
            collectionViewLayout: UICollectionViewFlowLayout())
        let sessionsTab = Tabs.sessions
        sessionsCollectionViewController.tabBarItem = UITabBarItem(title: sessionsTab.title,
                                                                   image: sessionsTab.image,
                                                                   tag: sessionsTab.rawValue)

        let stopwatchViewController = StopwatchViewController()
        let stopwatchTab = Tabs.stopwatch
        stopwatchViewController.tabBarItem = UITabBarItem(title: stopwatchTab.title,
                                                          image: stopwatchTab.image,
                                                          tag: stopwatchTab.rawValue)

        viewControllers = [profileViewController,
                           exercisesTableViewController,
                           sessionsCollectionViewController,
                           stopwatchViewController].map {
            UINavigationController(rootViewController: $0)
        }
        selectedIndex = selectedTab.rawValue
    }

    private func showOnboardingIfNeeded() {
        if User.isFirstTimeLoad {
            let onboardingPageViewController = OnboardingPageViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal)
            present(onboardingPageViewController, animated: true)
        }
    }

    private func updateSessionProgressObservingViewControllers(state: SessionState) {
        viewControllers?.forEach {
            if let viewControllers = ($0 as? UINavigationController)?.viewControllers,
               let viewController = viewControllers.first as? SessionProgressDelegate {
                switch state {
                case .start:
                    viewController.sessionDidStart(nil)
                case .end:
                    viewController.sessionDidEnd(nil)
                }
            }
        }
    }
}

// MARK: - SessionProgressDelegate
extension MainTabBarController: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        if isSessionInProgress {
            guard let startSessionViewController = startSessionViewController else {
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
                                        startSessionViewController.dismissAsChildViewController()
                                      })
            presentCustomAlert(alertData: alertData)
        } else {
            startSession(session)
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

        let startSessionViewController = StartSessionTableViewController()
        startSessionViewController.session = session
        startSessionViewController.sessionProgresssDelegate = self
        startSessionViewController.dimmedView = dimmedView
        startSessionViewController.panView = shadowContainerView
        startSessionViewController.initialTabBarFrame = tabBar.frame
        // This allows startSessionViewController to extend over the bottom tab bar
        startSessionViewController.extendedLayoutIncludesOpaqueBars = true

        let containerNavigationController = UINavigationController(
            rootViewController: startSessionViewController)
        containerNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        containerNavigationController.view.addCorner(style: .small)

        shadowContainerView.addSubview(containerNavigationController.view)
        containerNavigationController.view.autoPinSafeEdges(to: shadowContainerView)

        self.startSessionViewController = startSessionViewController

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

    func sessionDidEnd(_ session: Session?) {
        isSessionInProgress = false
        startSessionViewController = nil

        if isReplacingSession, sessionToReplace != nil {
            isReplacingSession = false
            startSession(sessionToReplace)
        } else {
            updateSessionProgressObservingViewControllers(state: .end)
        }
    }
}
