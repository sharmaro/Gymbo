//
//  TabBarController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TabBarController: UITabBarController {
    class var id: String {
        return String(describing: self)
    }

    var isSessionInProgress = false

    private var selectedTab = SelectedTab.sessions
}

// MARK: - Structs/Enums
private extension TabBarController {
    enum SelectedTab: Int {
        case exercises = 0
        case sessions
        case stopwatch
    }
}

// MARK: - UITabBarController Var/Funcs
extension TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }
}

// MARK: - Funcs
extension TabBarController {
    private func setupTabBar() {
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black

        selectedIndex = selectedTab.rawValue
    }
}
