//
//  ProfileTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileTVC: UITableViewController {
    var customDataSource: ProfileTVDS?
    var customDelegate: ProfileTVD?

    private let settingsButton = CustomButton()
    private let settingsView: UIView = {
        let frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))
        let containerView = UIView(frame: frame)

        let button = CustomButton(frame: frame)
        let settingsImage = UIImage(named: "settings")
        button.setImage(settingsImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        containerView.addSubview(button)
        return containerView
    }()
}

// MARK: - Structs/Enums
private extension ProfileTVC {
}

// MARK: - UIViewController Var/Funcs
extension ProfileTVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ProfileTVC: ViewAdding {
    func setupNavigationBar() {
        title = "Profile"

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsView)

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
    }

    func setupViews() {
        if let settingsButton = settingsView.subviews.first as? CustomButton {
            settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        }

        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .dynamicWhite }
    }

    func addConstraints() {
    }
}

// MARK: - Funcs
extension ProfileTVC {
    private func renewConstraints() {
        guard isViewLoaded,
              let mainTBC = mainTBC else {
            return
        }

        if mainTBC.isSessionInProgress {
        } else {
        }

        UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    @objc private func settingsButtonTapped() {
        Haptic.sendSelectionFeedback()

        let settingsTVC = SettingsTVC(style: .grouped)
        let navigationController = MainNC(rootVC: settingsTVC)
        self.navigationController?.present(navigationController, animated: true)
    }
}

// MARK: ListDataSource
extension ProfileTVC: ListDataSource {
}

// MARK: - ListDelegate
extension ProfileTVC: ListDelegate {
}

// MARK: - KeyboardObserving
extension ProfileTVC: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = notification.keyboardSize?.height,
              tableView.numberOfSections > 0 else {
            return
        }
        tableView.contentInset.bottom = keyboardHeight
    }

    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}

// MARK: - SessionProgressDelegate
extension ProfileTVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        renewConstraints()
    }
}
