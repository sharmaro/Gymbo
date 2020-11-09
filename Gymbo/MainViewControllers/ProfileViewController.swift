//
//  ProfileViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileViewController: UIViewController {
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
        let frame = CGRect(origin: .zero, size: CGSize(width: 20, height: 20))
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
extension ProfileViewController {
    private struct Constants {
    }
}

// MARK: - UIViewController Var/Funcs
extension ProfileViewController {
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
extension ProfileViewController: ViewAdding {
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
        [view, tableView].forEach { $0.backgroundColor = .mainWhite }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            // Using top anchor instead of safe area to get smooth navigation title size change animation
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
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
extension ProfileViewController {
    @objc private func settingsButtonTapped() {
        Haptic.sendSelectionFeedback()

        let settingsTableViewController = SettingsTableViewController()
        let navigationController = UINavigationController(rootViewController: settingsTableViewController)
        self.navigationController?.present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }
}

// MARK: - UITableViewDelegate
extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        Haptic.sendSelectionFeedback()
    }
}

// MARK: - KeyboardObserving
extension ProfileViewController: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        guard let mainTabBarController = navigationController?.mainTabBarController,
            let keyboardHeight = notification.keyboardSize?.height else {
            return
        }

        let bottomInset = abs(mainTabBarController.view.frame.height - keyboardHeight - tableView.frame.maxY)
        tableView.contentInset.bottom = bottomInset
    }

    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}

// MARK: - SessionProgressDelegate
extension ProfileViewController: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?) {
        renewConstraints()
    }
}

// MARK: - SessionStateConstraintsUpdating
extension ProfileViewController: SessionStateConstraintsUpdating {
    func renewConstraints() {
        guard let mainTabBarController = mainTabBarController else {
            return
        }

        if mainTabBarController.isSessionInProgress {
        } else {
        }

        UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}
