//
//  ProfileDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
struct ProfileDataModel {
    private let tableItems: [[TableItem]] = [
        [
        ]
    ]
}

// MARK: - Structs/Enums
extension ProfileDataModel {
    private struct Constants {
    }

    enum TableItem: String {
        case none

        var height: CGFloat {
//            switch self {
//            case .:
//            }
            return 0
        }
    }
}

// MARK: - Funcs
extension ProfileDataModel {
    // MARK: - Helpers
    private func validateSection(section: Int) -> Bool {
        section < tableItems.count
    }

    func indexOf(item: TableItem) -> Int? {
        var index: Int?
        tableItems.forEach {
            if $0.contains(item) {
                index = $0.firstIndex(of: item)
                return
            }
        }
        return index
    }
}

// MARK: - UITableViewDataSource
extension ProfileDataModel {
    var numberOfSections: Int {
        tableItems.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard validateSection(section: section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }
        return tableItems[section].count
    }

    func cellForRow(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }

//        let cell: UITableViewCell
//        let item = tableItems[indexPath.section][indexPath.row]
//
//        switch item {
//        case .:
//        }
//        return cell
        return UITableViewCell()
    }

    func tableItem(at indexPath: IndexPath) -> TableItem {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }
        return tableItems[indexPath.section][indexPath.row]
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }
        return tableItems[indexPath.section][indexPath.row].height
    }
}
