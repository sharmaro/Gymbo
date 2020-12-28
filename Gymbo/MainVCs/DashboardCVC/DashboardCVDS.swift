//
//  DashboardCVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DashboardCVDS: NSObject {
    private let collectionItems: [[CollectionItem]] = [
        [
            .history
        ]
    ]

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?) {
        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension DashboardCVDS {
    private struct Constants {
    }

    enum CollectionItem: String {
        case history

        var height: CGFloat {
            0
        }
    }
}

// MARK: - Funcs
extension DashboardCVDS {
}

// MARK: - UICollectionViewDataSource
extension DashboardCVDS: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        collectionItems[section].count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        UICollectionReusableView()
    }
}
