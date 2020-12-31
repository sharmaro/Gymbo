//
//  MainNC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/25/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class MainNC: UINavigationController {
    weak var rootVC: UIViewController?

    init() {
        self.rootVC = nil
        super.init(rootViewController: UIViewController())
    }

    init(rootVC: UIViewController) {
        self.rootVC = rootVC
        super.init(rootViewController: rootVC)
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIViewController Var/Funcs
extension MainNC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension MainNC: ViewAdding {
    func setupNavigationBar() {
        // This allows there to be a smooth transition from large title to small and vice-versa
//        navigationController?.navigationBar.prefersLargeTitles = true
//        extendedLayoutIncludesOpaqueBars = true
//        edgesForExtendedLayout = .all
    }

    func setupColors() {
        view.backgroundColor = .dynamicWhite
    }
}

// MARK: - Funcs
extension MainNC {}
