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
    private let settingsDataModel = SettingsDataModel()

    private var selectedIndexPath: IndexPath?
    private var didUpdateSelection = false
}

// MARK: - Structs/Enums
private extension SettingsTableViewController {
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
        settingsDataModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        settingsDataModel.cellForRow(in: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension SettingsTableViewController {
    override func tableView(_ tableView: UITableView,
                            estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        settingsDataModel.heightForRow(at: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        settingsDataModel.heightForRow(at: indexPath)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()

        let item = settingsDataModel.tableItem(at: indexPath)
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

        let tableItem = settingsDataModel.tableItem(at: indexPath)
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
