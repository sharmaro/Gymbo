//
//  SettingsTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import MessageUI

// MARK: - Properties
class SettingsTVC: UITableViewController {
    var customDataSource: SettingsTVDS?
    var customDelegate: SettingsTVD?
}

// MARK: - Structs/Enums
private extension SettingsTVC {
    struct Constants {
        static let gymboEmail = "gymbo.feedback@gmail.com"
        static let emailSubject = "Support"
    }
}

// MARK: - UIViewController Var/Funcs
extension SettingsTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
        setupColors()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let customDataSource = customDataSource else {
            return
        }

        if customDataSource.didUpdateSelection,
           let selectedIndexPath = customDataSource.selectedIndexPath {
            customDataSource.didUpdateSelection = false
            customDataSource.selectedIndexPath = nil
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SettingsTVC: ViewAdding {
    func setupNavigationBar() {
        title = "Settings"
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.delaysContentTouches = false
        tableView.sectionFooterHeight = 0
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(ExercisesHFV.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHFV.reuseIdentifier)
        tableView.register(SelectionTVCell.self,
                           forCellReuseIdentifier: SelectionTVCell.reuseIdentifier)
    }

    func setupColors() {
        view.backgroundColor = .primaryBackground
    }
}

// MARK: - Funcs
extension SettingsTVC {
    private func presentSelectionTVC(with item: SettingsItem) {
        let selectionTVC = VCFactory.makeSelectionTVC(items: item.selectionItems,
                                                      selected: item.value,
                                                      title: item.title,
                                                      delegate: self)
        navigationController?.pushViewController(selectionTVC, animated: true)
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
            let alertData = AlertData(title: "Oops!",
                                      content: "Sorry, we can't send mail right now",
                                      usesBothButtons: false,
                                      rightButtonTitle: "Sounds good")
            presentCustomAlert(alertData: alertData)
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

// MARK: - ListDelegate
extension SettingsTVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let customDataSource = customDataSource else {
            return
        }
        Haptic.sendSelectionFeedback()

        let item = customDataSource.item(at: indexPath)
        let settingsItem = customDataSource.settingsItem(from: item)
        switch item {
        case .theme, .weight:
            presentSelectionTVC(with: settingsItem)
        case .contactUs:
            contactUsSelected()
        }
        customDataSource.selectedIndexPath = indexPath
    }
}

// MARK: - SelectionDelegate
extension SettingsTVC: SelectionDelegate {
    func selected(item: String) {
        guard let indexPath = customDataSource?.selectedIndexPath,
              let customDataSource = customDataSource else {
            fatalError("Incorrect index path selected.")
        }

        let tableItem = customDataSource.item(at: indexPath)

        let settingsItem = customDataSource.settingsItem(from: tableItem)
        guard settingsItem.value != item else {
            customDataSource.didUpdateSelection = false
            customDataSource.selectedIndexPath = nil
            return
        }

        switch tableItem {
        case .theme:
            guard let mode = UserInterfaceMode(rawValue: item) else {
                fatalError("Incorrect raw value used to initialize UserInterfaceMode.")
            }
            UserInterfaceMode.setUserInterfaceMode(with: mode)
        case .weight:
            customDataSource.selectedWeight(settingsText: item)
        case .contactUs:
            break
        }
        customDataSource.didUpdateSelection = true
    }
}
