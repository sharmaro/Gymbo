//
//  AllSessionsCVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/1/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionsCVC: UICollectionViewController {
    private var segmentedControl: UISegmentedControl?

    var customDataSource: AllSessionsCVDS?
    var customDelegate: AllSessionsCVD?
}

// MARK: - UIViewController Var/Funcs
extension AllSessionsCVC {
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
extension AllSessionsCVC: ViewAdding {
    func setupNavigationBar() {
        title = "Past Sessions"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }

    func setupViews() {
        let items = customDataSource?.segmentedControlItems
        segmentedControl = UISegmentedControl(items: items ?? [])
        segmentedControl?.selectedSegmentIndex = 0
        segmentedControl?.addTarget(self, action: #selector(segmentedControlValueChanged),
                                   for: .valueChanged)
        navigationItem.titleView = segmentedControl

        collectionView.dataSource = customDataSource
        collectionView.delegate = customDelegate

        collectionView.register(AllSessionsCVCell.self,
                                forCellWithReuseIdentifier: AllSessionsCVCell.reuseIdentifier)
    }

    func setupColors() {
        [view, collectionView].forEach { $0.backgroundColor = .dynamicWhite }
    }
}

// MARK: - Funcs
extension AllSessionsCVC {
    private func reloadCVAndScrollToTop() {
        collectionView.reloadData()
        if collectionView.numberOfSections > 0,
           collectionView.numberOfItems(inSection: 0) > 0 {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            collectionView.scrollToItem(at: firstIndexPath,
                                        at: .bottom, animated: true)
        }
    }

    @objc private func closeButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
    }

    @objc private func segmentedControlValueChanged(_ sender: Any) {
        guard let selectedIndex = (sender as? UISegmentedControl)?
                .selectedSegmentIndex else {
            return
        }
        Haptic.sendSelectionFeedback()

        customDataSource?.itemModeChanged(to: selectedIndex)
        reloadCVAndScrollToTop()
    }
}

// MARK: ListDataSource
extension AllSessionsCVC: ListDataSource {
    func reloadData() {
        collectionView.reloadWithoutAnimation()
    }
}

// MARK: - ListDelegate
extension AllSessionsCVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let session = customDataSource?.session(for: indexPath.row) else {
            return
        }
        Haptic.sendSelectionFeedback()

        let allSessionsDetailTVC = VCFactory.makeAllSessionsDetailTVC(session: session)
        navigationController?.pushViewController(allSessionsDetailTVC, animated: true)
    }
}
