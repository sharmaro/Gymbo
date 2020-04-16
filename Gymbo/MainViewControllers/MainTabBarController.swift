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

    private var selectedTab = SelectedTab.sessions
}

// MARK: - Structs/Enums
private extension MainTabBarController {
    enum SelectedTab: Int {
        case exercises = 0
        case sessions
        case stopwatch
    }
}

// MARK: - UITabBarController Var/Funcs
extension MainTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }
}

// MARK: - Funcs
extension MainTabBarController {
    private func setupTabBar() {
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black

        let exercisesViewController = ExercisesViewController()
        let exercisesTabImage = UIImage(named: "my_exercises")
        exercisesViewController.tabBarItem = UITabBarItem(title: "My Exercises", image: exercisesTabImage, tag: 0)

        // Need to initialize a UICollectionView with a UICollectionViewLayout
        let sessionsCollectionViewController = SessionsCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        let sessionsTabImage = UIImage(named: "dumbbell")
        sessionsCollectionViewController.tabBarItem = UITabBarItem(title: "Sessions", image: sessionsTabImage, tag: 1)

        let stopwatchViewController = StopwatchViewController()
        let stopwatchTabImage = UIImage(named: "stopwatch")
        stopwatchViewController.tabBarItem = UITabBarItem(title: "Stopwatch", image: stopwatchTabImage, tag: 2)

        viewControllers = [exercisesViewController, sessionsCollectionViewController, stopwatchViewController].map {
            UINavigationController(rootViewController: $0)
        }

        selectedIndex = selectedTab.rawValue
    }
}
