//
//  ChildViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 4/4/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ChildNavigationController: UINavigationController {
    private var hideNavigationBar = false {
        didSet {
            isNavigationBarHidden = hideNavigationBar
        }
    }

    init(rootViewController: UIViewController, hideNavigationBar: Bool) {
        super.init(rootViewController: rootViewController)

        self.hideNavigationBar = hideNavigationBar
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }
}

// MARK: - Structs/Enums
extension ChildNavigationController {

}

// MARK: - UIViewController Var/Funcs
extension ChildNavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Funcs
extension ChildNavigationController {
    private func setup() {

    }
}
