//
//  DashboardCVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DashboardCVC: UICollectionViewController {
    var customDataSource: DashboardCVDS?
    var customDelegate: DashboardCVD?
}

// MARK: - Structs/Enums
private extension DashboardCVC {
}

// MARK: - UIViewController Var/Funcs
extension DashboardCVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension DashboardCVC: ViewAdding {
    func setupNavigationBar() {
        title = "Dashboard"

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
    }

    func setupViews() {
        collectionView.dataSource = customDataSource
        collectionView.delegate = customDelegate
    }

    func setupColors() {
        collectionView.backgroundColor = .dynamicWhite
    }

    func addConstraints() {
    }
}

// MARK: - Funcs
extension DashboardCVC {
}

// MARK: - ListDataSource
extension DashboardCVC: ListDataSource {
}

// MARK: - ListDelegate
extension DashboardCVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
    }
}