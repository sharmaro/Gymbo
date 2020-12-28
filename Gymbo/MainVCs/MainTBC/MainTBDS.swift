//
//  MainTBDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/27/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class MainTBDS: NSObject {
    var selectedTab = Tab.sessions
    var viewControllers: [MainNC]?

    override init() {
        super.init()

        setupVCs()
    }
}

// MARK: - Structs/Enums
extension MainTBDS {
    //swiftlint:disable:next type_name
    enum Tab: Int {
        case profile
        case dashboard
        case sessions
        case exercises
        case stopwatch

        var title: String {
            let text: String
            switch self {
            case .profile:
                text = "Profile"
            case .dashboard:
                text = "Dashboard"
            case .sessions:
                text = "Sessions"
            case .exercises:
                text = "My Exercises"
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
            case .dashboard:
                imageName = "dashboard"
            case .sessions:
                imageName = "dumbbell"
            case .exercises:
                imageName = "my_exercises"
            case .stopwatch:
                imageName = "stopwatch"
            }
            return UIImage(named: imageName) ?? UIImage()
        }
    }
}

// MARK: - Funcs
extension MainTBDS {
    private func setupVCs() {
        let profileTab = Tab.profile
        let profileTVC = VCFactory.makeProfileTVC()
        profileTVC.tabBarItem = UITabBarItem(title: profileTab.title,
                                            image: profileTab.image,
                                            tag: profileTab.rawValue)

        // Need to initialize a UICollectionView with a UICollectionViewLayout
        let dashboardTab = Tab.dashboard
        let dashboardCVC = VCFactory.makeDashboardCVC(
            layout: UICollectionViewFlowLayout())
        dashboardCVC.tabBarItem = UITabBarItem(title: dashboardTab.title,
                                              image: dashboardTab.image,
                                              tag: dashboardTab.rawValue)

        let sessionsTab = Tab.sessions
        let sessionsCVC = SessionsCVC(
            collectionViewLayout: UICollectionViewFlowLayout())
        sessionsCVC.tabBarItem = UITabBarItem(title: sessionsTab.title,
                                              image: sessionsTab.image,
                                              tag: sessionsTab.rawValue)

        let exercisesTab = Tab.exercises
        let exercisesTVC = VCFactory.makeExercisesTVC(
            style: .grouped)
        exercisesTVC.tabBarItem = UITabBarItem(title: exercisesTab.title,
                                               image: exercisesTab.image,
                                               tag: exercisesTab.rawValue)

        let stopwatchTab = Tab.stopwatch
        let stopwatchVC = StopwatchVC()
        stopwatchVC.tabBarItem = UITabBarItem(title: stopwatchTab.title,
                                              image: stopwatchTab.image,
                                              tag: stopwatchTab.rawValue)

        viewControllers = [
            profileTVC,
            dashboardCVC,
            sessionsCVC,
            exercisesTVC,
            stopwatchVC].map {
                MainNC(rootVC: $0)
        }
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTBDS: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController,
                                 didSelect viewController: UIViewController) {
        selectedTab = Tab(rawValue: tabBarController.selectedIndex) ?? .sessions
    }
}
