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
        ]
    ]
}

// MARK: - Structs/Enums
extension SettingsDataModel {
    private struct Constants {
        static let settingsCellHeight = CGFloat(70)
    }

    enum TableItem: String {
        case theme = "Theme"

        var value: String {
            let response: String
            switch self {
            case .theme:
                response = UserInterfaceMode.currentMode.rawValue
            }
            return response
        }

        var selectionItems: [String] {
            let response: [String]
            switch self {
            case .theme:
                response = UserInterfaceMode.allCases.map { $0.rawValue }
            }
            return response
        }

        var height: CGFloat {
            let response: CGFloat
            switch self {
            case .theme:
                response = Constants.settingsCellHeight
            }
            return response
        }
    }
}

// MARK: - Funcs
extension SettingsDataModel {
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

    private func getSelectionCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> SelectionTableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SelectionTableViewCell.reuseIdentifier,
                for: indexPath) as? SelectionTableViewCell else {
            fatalError("Could not dequeue \(SelectionTableViewCell.reuseIdentifier)")
        }

        let item = tableItems[indexPath.section][indexPath.row]
        cell.configure(title: item.rawValue, value: item.value, imageName: "right_arrow")
        return cell
    }

    // Helpers
    private func validateSection(section: Int) -> Bool {
        section < tableItems.count
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
        case .theme:
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
