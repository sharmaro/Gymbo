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
        navigationBar.prefersLargeTitles = true
        // This allows there to be a smooth transition from large title to small and vice-versa
        rootVC?.extendedLayoutIncludesOpaqueBars = true
        rootVC?.edgesForExtendedLayout = .all
    }

    func setupViews() {
        delegate = self
    }

    func setupColors() {
        view.backgroundColor = .primaryBackground
    }
}

// MARK: - Funcs
extension MainNC {}

// MARK: - UINavigationControllerDelegate
extension MainNC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        viewController.extendedLayoutIncludesOpaqueBars = true
        viewController.edgesForExtendedLayout = .all
    }
}
