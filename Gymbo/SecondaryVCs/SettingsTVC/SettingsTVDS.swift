//
//  SettingsTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class SettingsTVDS: NSObject {
    var selectedIndexPath: IndexPath?
    var didUpdateSelection = false
    private var user: User?

    private let items: [[Item]] = [
        [
            .theme, .weight
        ],
        [
            .contactUs
        ]
    ]

    init(user: User?) {
        self.user = user
        super.init()
    }
}

// MARK: - Structs/Enums
extension SettingsTVDS {
    enum Item: String {
        case theme = "Theme"
        case weight = "Weight"
        case contactUs = "Contact Us"
    }
}

// MARK: - Funcs
extension SettingsTVDS {
    // Helpers
    private func value(for item: Item) -> String {
        let response: String
        switch item {
        case .theme:
            response = UserInterfaceMode.currentMode.rawValue
        case .weight:
            let intType = user?.preferredWeightType ?? 0
            let type = WeightType(rawValue: intType) ?? .lbs
            response = type.settingsText
        case .contactUs:
            response = ""
        }
        return response
    }

    private func selectionItems(for item: Item) -> [String] {
        let response: [String]
        switch item {
        case .theme:
            response = UserInterfaceMode.allCases.map { $0.rawValue }
        case .weight:
            response = WeightType.allCases.map { $0.settingsText }
        case .contactUs:
            response = []
        }
        return response
    }

    private func leftImage(for item: Item) -> UIImage? {
        let imageName: String
        switch item {
        case .theme:
            return nil
        case .weight:
            return nil
        case .contactUs:
            imageName = "mail"
        }
        return UIImage(named: imageName)
    }

    private func rightImage(for item: Item) -> UIImage? {
        let imageName: String
        switch item {
        case .theme, .weight:
            imageName = "right_arrow"
        case .contactUs:
            return nil
        }
        return UIImage(named: imageName)
    }

    // MARK: - UITableViewCells
    private func getSelectionCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> SelectionTVCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SelectionTVCell.reuseIdentifier,
                for: indexPath) as? SelectionTVCell else {
            fatalError("Could not dequeue \(SelectionTVCell.reuseIdentifier)")
        }

        let item = items[indexPath.section][indexPath.row]
        let leftImage = self.leftImage(for: item)
        let value = self.value(for: item)
        let rightImage = self.rightImage(for: item)
        cell.configure(leftImage: leftImage,
                       title: item.rawValue,
                       value: value,
                       rightImage: rightImage)
        return cell
    }

    func item(at indexPath: IndexPath) -> Item {
        items[indexPath.section][indexPath.row]
    }

    func settingsItem(from item: Item) -> SettingsItem {
        let value = self.value(for: item)
        let selectionItems = self.selectionItems(for: item)
        let leftImage = self.leftImage(for: item)
        let rightImage = self.rightImage(for: item)
        let settingsItem = SettingsItem(title: item.rawValue,
                                        value: value,
                                        selectionItems: selectionItems,
                                        leftImage: leftImage,
                                        rightImage: rightImage)
        return settingsItem
    }

    func selectedWeight(settingsText: String) {
        let rawValue = WeightType.rawValue(from: settingsText)
        let realm = try? Realm()
        try? realm?.write {
            user?.preferredWeightType = rawValue
        }
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
        case .theme, .weight, .contactUs:
            cell = getSelectionCell(in: tableView, for: indexPath)
        }
        Utility.configureCellRounding(in: tableView,
                                      with: cell,
                                      for: indexPath)
        return cell
    }
}
