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
    }

    func addViews() {
    }

    func setupViews() {
        collectionView.dataSource = customDataSource
        collectionView.delegate = customDelegate

        collectionView.alwaysBounceVertical = true
        collectionView.register(DashboardCVCell.self,
                                forCellWithReuseIdentifier: DashboardCVCell.reuseIdentifier)
    }

    func setupColors() {
        collectionView.backgroundColor = .dynamicWhite
    }

    func addConstraints() {
    }
}

// MARK: - Funcs
extension DashboardCVC {
    private func presentAllSessionsCVC() {
        let allSessionsCVC = VCFactory.makeAllSessionsCVC(
            user: customDataSource?.user)
        let mainNC = MainNC(rootVC: allSessionsCVC)
        navigationController?.present(mainNC, animated: true)
    }

    private func presentAllSessionDaysCVC() {
        let allSessionDaysCVC = VCFactory.makeAllSessionDaysCVC(
            user: customDataSource?.user,
            date: Date())
        let mainNC = MainNC(rootVC: allSessionDaysCVC)
        navigationController?.present(mainNC, animated: true)
    }
}

// MARK: - ListDataSource
extension DashboardCVC: ListDataSource {
}

// MARK: - ListDelegate
extension DashboardCVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let item = customDataSource?.item(for: indexPath) else {
            return
        }
        Haptic.sendSelectionFeedback()

        switch item {
        case .pastSessions:
            presentAllSessionsCVC()
        case .sessionDays:
            presentAllSessionDaysCVC()
        }
    }
}

// MARK: - SessionProgressDelegate
extension DashboardCVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        // Implement this
        collectionView.contentInset.bottom = .zero
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        collectionView.contentInset = .zero
        collectionView.reloadWithoutAnimation()
    }
}
