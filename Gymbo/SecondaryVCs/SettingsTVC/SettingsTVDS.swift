//
//  SettingsTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SettingsTVDS: NSObject {
    var selectedIndexPath: IndexPath?
    var didUpdateSelection = false

    private let items: [[Item]] = [
        [
            .theme
        ],
        [
            .contactUs
        ]
    ]
}

// MARK: - Structs/Enums
extension SettingsTVDS {
    enum Item: String {
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
    }
}

// MARK: - Funcs
extension SettingsTVDS {
    // MARK: - UITableViewCells
    private func getSelectionCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> SelectionTVCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SelectionTVCell.reuseIdentifier,
                for: indexPath) as? SelectionTVCell else {
            fatalError("Could not dequeue \(SelectionTVCell.reuseIdentifier)")
        }

        let item = items[indexPath.section][indexPath.row]
        cell.configure(leftImage: item.leftImage,
                       title: item.rawValue,
                       value: item.value,
                       rightImage: item.rightImage)
        return cell
    }

    func item(at indexPath: IndexPath) -> Item {
        items[indexPath.section][indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension SettingsTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let item = items[indexPath.section][indexPath.row]

        switch item {
        case .theme, .contactUs:
            cell = getSelectionCell(in: tableView, for: indexPath)
        }
        return cell
    }
}
