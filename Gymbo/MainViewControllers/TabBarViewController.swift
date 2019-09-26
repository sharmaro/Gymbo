//
//  TabBarController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupTabBarItems()
    }
    
    func setupTabBar() {
        tabBar.backgroundColor = Layout.Colors.darkGray
        tabBar.barTintColor = Layout.Colors.darkGray
    }
    
    func setupTabBarItems() {
        tabBar.tintColor = Layout.Colors.mainOrange // Color for selected item
        tabBar.unselectedItemTintColor = Layout.Colors.white // Color for unselected item
    }
}
