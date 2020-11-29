//
//  SettingsTableViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import MessageUI

// MARK: - Properties
class SettingsTableViewController: UITableViewController {
    private let settingsDataModel = SettingsDataModel()

    private var selectedIndexPath: IndexPath?
    private var didUpdateSelection = false
}

// MARK: - Structs/Enums
private extension SettingsTableViewController {
    struct Constants {
        static let gymboEmail = "gymbo.feedback@gmail.com"
        static let emailSubject = "Support"

        static let headerHeight = CGFloat(40)
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
        tableView.sectionFooterHeight = 0
        tableView.tableFooterView = UIView()
        tableView.register(ExercisesHeaderFooterView.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHeaderFooterView.reuseIdentifier)
        tableView.register(SelectionTableViewCell.self,
                           forCellReuseIdentifier: SelectionTableViewCell.reuseIdentifier)
    }

    func setupColors() {
        view.backgroundColor = .mainWhite
    }
}

// MARK: - Funcs
extension SettingsTableViewController {
    private func presentSelectionScreen(with item: SettingsDataModel.TableItem) {
        let tableViewController = SelectionTableViewController(items: item.selectionItems,
                                                               selected: item.value,
                                                               title: item.rawValue)
        tableViewController.selectionDelegate = self
        navigationController?.pushViewController(tableViewController, animated: true)
    }

    func contactUsSelected() {
        if MFMailComposeViewController.canSendMail() {
            let mailViewController = MFMailComposeViewController()
            mailViewController.mailComposeDelegate = self
            mailViewController.setToRecipients([Constants.gymboEmail])
            mailViewController.setSubject(Constants.emailSubject)
            mailViewController.setMessageBody(emailBody, isHTML: false)
            navigationController?.present(mailViewController, animated: true)
        } else {
            presentCustomAlert(title: "Oops",
                               content: "Sorry, we can't send mail right now",
                               usesBothButtons: false,
                               rightButtonTitle: "Sounds good")
        }
    }

    private var emailBody: String {
        var body = "\n\n\n"
        for _ in 0 ..< 20 {
            body.append("-")
        }
        body.append("\n")
        body.append(Utility.formattedDeviceInfo)
        return body
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        settingsDataModel.numberOfSections
    }

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
                            estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : Constants.headerHeight
    }

    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0 : Constants.headerHeight
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0,
              let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ExercisesHeaderFooterView.reuseIdentifier) as? ExercisesHeaderFooterView else {
            return nil
        }
        return headerView
    }

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
        switch item {
        case .theme:
            presentSelectionScreen(with: item)
        case .contactUs:
            contactUsSelected()
        }

        selectedIndexPath = indexPath
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
        case .contactUs:
            break
        }
        didUpdateSelection = true
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
