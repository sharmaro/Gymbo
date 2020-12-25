//
//  ProfileVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileVC: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.allowsMultipleSelection = true
        tableView.delaysContentTouches = false
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        return tableView
    }()

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

    private var profileDataModel = ProfileDataModel()
}

// MARK: - Structs/Enums
extension ProfileVC {
    private struct Constants {
    }
}

// MARK: - UIViewController Var/Funcs
extension ProfileVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ProfileVC: ViewAdding {
    func setupNavigationBar() {
        title = "Profile"

        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: settingsView)

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView])
    }

    func setupViews() {
        if let settingsButton = settingsView.subviews.first as? CustomButton {
            settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        }

        tableView.dataSource = self
        tableView.delegate = self
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .dynamicWhite }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            // Using top anchor instead of safe area to get smooth navigation title size change animation
            tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

// MARK: - Funcs
extension ProfileVC {
    @objc private func settingsButtonTapped() {
        Haptic.sendSelectionFeedback()

        let settingsTVC = SettingsTVC(style: .grouped)
        let navigationController = MainNC(rootVC: settingsTVC)
        self.navigationController?.present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ProfileVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        profileDataModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        profileDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        profileDataModel.cellForRow(in: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ProfileVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        profileDataModel.heightForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        profileDataModel.heightForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
    }
}

// MARK: - KeyboardObserving
extension ProfileVC: KeyboardObserving {
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
extension ProfileVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?) {
        renewConstraints()
    }
}

// MARK: - SessionStateConstraintsUpdating
extension ProfileVC: SessionStateConstraintsUpdating {
    func renewConstraints() {
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
}
