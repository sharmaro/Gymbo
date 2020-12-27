//
//  DashboardDataSource.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DashboardDataSource: NSObject {
    private let collectionItems: [[CollectionItem]] = [
        [
            .history
        ]
    ]
}

// MARK: - Structs/Enums
extension DashboardDataSource {
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
extension DashboardDataSource {
    // MARK: - Helpers
    private func validateSection(section: Int) -> Bool {
        section < collectionItems.count
    }

    func indexOf(item: CollectionItem) -> Int? {
        var index: Int?
        collectionItems.forEach {
            if $0.contains(item) {
                index = $0.firstIndex(of: item)
                return
            }
        }
        return index
    }
}

// MARK: - UICollectionViewDataSource
extension DashboardDataSource: UICollectionViewDataSource {
    func tableItem(at indexPath: IndexPath) -> CollectionItem {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(collectionItems.count)")
        }
        return collectionItems[indexPath.section][indexPath.row]
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        collectionItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        collectionItems[section].count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        UICollectionReusableView()
    }
}
