//
//  TabBarController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    // MARK: - Properties
    class var id: String {
        return String(describing: self)
    }
}

// MARK: - UITabBarController Var/Funcs
extension TabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
        setupTabBarItems()
    }
}

// MARK: - Funcs
extension TabBarController {
    private func setupTabBar() {
        tabBar.backgroundColor = .black
        tabBar.barTintColor = .black
    }

    private func setupTabBarItems() {
//        tabBar.tintColor = Layout.Colors.mainOrange // Color for selected item
//        tabBar.unselectedItemTintColor = Layout.Colors.white // Color for unselected item
    }
}
