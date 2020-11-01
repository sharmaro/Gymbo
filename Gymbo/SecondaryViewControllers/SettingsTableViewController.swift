//
//  SettingsTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SettingsTableViewController: UITableViewController {
    private var tableData: [TableRow] = [.theme]
    private var selectedIndexPath: IndexPath?
    private var didUpdateSelection = false
}

// MARK: - Structs/Enums
private extension SettingsTableViewController {
    struct Constants {
        static let settingsCellHeight = CGFloat(70)
    }

    enum TableRow: String {
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

// MARK: - UIViewController Var/Funcs
extension SettingsTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if didUpdateSelection,
           let selectedIndexPath = selectedIndexPath {
            didUpdateSelection = false
            self.selectedIndexPath = nil
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SettingsTableViewController: ViewAdding {
    func setupNavigationBar() {
        title = "Settings"

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func setupViews() {
        tableView.delaysContentTouches = false
        tableView.tableFooterView = UIView()
        tableView.register(SelectionTableViewCell.self,
                           forCellReuseIdentifier: SelectionTableViewCell.reuseIdentifier)
    }

    func setupColors() {
        view.backgroundColor = .mainWhite
    }
}

// MARK: - Funcs
extension SettingsTableViewController {
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SelectionTableViewCell.reuseIdentifier,
                for: indexPath) as? SelectionTableViewCell else {
            fatalError("Could not dequeue \(SelectionTableViewCell.reuseIdentifier)")
        }

        let item = tableData[indexPath.row]
        cell.configure(title: item.rawValue, value: item.value, imageName: "right_arrow")
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = tableData[indexPath.row]
        return item.height
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = tableData[indexPath.row]
        return item.height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = tableData[indexPath.row]
        let tableViewController = SelectionTableViewController(items: item.selectionItems,
                                                               selected: item.value,
                                                               title: item.rawValue)
        tableViewController.selectionDelegate = self
        selectedIndexPath = indexPath
        navigationController?.pushViewController(tableViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SelectionDelegate
extension SettingsTableViewController: SelectionDelegate {
    func selected(item: String) {
        guard let indexPath = selectedIndexPath else {
            fatalError("Incorrect index path selected.")
        }

        let tableItem = tableData[indexPath.row]
        guard tableItem.value != item else {
            didUpdateSelection = false
            selectedIndexPath = nil
            return
        }

        switch tableItem {
        case .theme:
            guard let mode = UserInterfaceMode(rawValue: item) else {
                fatalError("Incorrect raw value used to initialize UserInterfaceMode.")
            }
            UserInterfaceMode.setUserInterfaceMode(with: mode)
        }

        didUpdateSelection = true
    }
}
