//
//  SettingsDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
struct SettingsDataModel {
    private let tableItems: [[TableItem]] = [
        [
            .theme
        ],
        [
            .contactUs
        ]
    ]
}

// MARK: - Structs/Enums
extension SettingsDataModel {
    private struct Constants {
        static let cellHeight = CGFloat(70)
    }

    enum TableItem: String {
        case theme = "Theme"
        case contactUs = "Contact Us"

        var value: String {
            let response: String
            switch self {
            case .theme:
                response = UserInterfaceMode.currentMode.rawValue
            case .contactUs:
                response = ""
            }
            return response
        }

        var selectionItems: [String] {
            let response: [String]
            switch self {
            case .theme:
                response = UserInterfaceMode.allCases.map { $0.rawValue }
            case .contactUs:
                response = []
            }
            return response
        }

        var leftImage: UIImage? {
            let imageName: String
            switch self {
            case .theme:
                return nil
            case .contactUs:
                imageName = "mail"
            }
            return UIImage(named: imageName)
        }

        var rightImage: UIImage? {
            let imageName: String
            switch self {
            case .theme:
                imageName = "right_arrow"
            case .contactUs:
                return nil
            }
            return UIImage(named: imageName)
        }

        var height: CGFloat {
            Constants.cellHeight
        }
    }
}

// MARK: - Funcs
extension SettingsDataModel {
    // MARK: - UITableViewCells
    private func getSelectionCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> SelectionTVCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SelectionTVCell.reuseIdentifier,
                for: indexPath) as? SelectionTVCell else {
            fatalError("Could not dequeue \(SelectionTVCell.reuseIdentifier)")
        }

        let item = tableItems[indexPath.section][indexPath.row]
        cell.configure(leftImage: item.leftImage,
                       title: item.rawValue,
                       value: item.value,
                       rightImage: item.rightImage)
        return cell
    }

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
extension SettingsDataModel {
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

        let cell: UITableViewCell
        let item = tableItems[indexPath.section][indexPath.row]

        switch item {
        case .theme, .contactUs:
            cell = getSelectionCell(in: tableView, for: indexPath)
        }
        return cell
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
