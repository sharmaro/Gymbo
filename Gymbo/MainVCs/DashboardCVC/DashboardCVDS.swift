//
//  DashboardCVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class DashboardCVDS: NSObject {
    private(set)var user: User?
    private let items = Item.allCases

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?, user: User?) {
        self.listDataSource = listDataSource
        self.user = user
    }
}

// MARK: - Structs/Enums
extension DashboardCVDS {
    private struct Constants {
    }

    enum Item: String, CaseIterable {
        case pastSessions = "All Sessions"
        case sessionDays = "Session Days"
    }
}

// MARK: - Funcs
extension DashboardCVDS {
    private func content(for item: Item) -> String {
        let response: String
        switch item {
        case .pastSessions:
            var pastSessionNames = "No sessions yet..."
            if let allPastSessionNames = user?.allSessionNames,
               !allPastSessionNames.isEmpty {
                pastSessionNames = allPastSessionNames.joined(separator: ", ")
            }
            response = pastSessionNames
        case .sessionDays:
            var dates = "No dates yet..."
            if let uniqueDates = user?.uniqueDates,
               !uniqueDates.isEmpty {
                dates = uniqueDates.map {
                    $0.formattedString(type: .short)
                }.joined(separator: ", ")
            }
            response = dates
        }
        return response
    }

    func item(for indexPath: IndexPath) -> Item {
        items[indexPath.row]
    }
}

// MARK: - UICollectionViewDataSource
extension DashboardCVDS: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dashboardCVCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DashboardCVCell.reuseIdentifier,
                for: indexPath) as? DashboardCVCell else {
            fatalError("Could not dequeue \(DashboardCVCell.reuseIdentifier)")
        }

        let item = items[indexPath.row]
        let content = self.content(for: item)
        dashboardCVCell.configure(title: item.rawValue, content: content)
        return dashboardCVCell
    }
}
