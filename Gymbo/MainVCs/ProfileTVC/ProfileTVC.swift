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
        button.tintColor = .dynamicBlack
        let settingsImage = UIImage(named: "settings")?
            .withRenderingMode(.alwaysTemplate)
        button.setImage(settingsImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit

        containerView.addSubview(button)
        return containerView
    }()

    private var profileTitleTVCell: ProfileTitleTVCell?
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
    }

    func addViews() {
    }

    func setupViews() {
        if let settingsButton = settingsView.subviews.first as? CustomButton {
            settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        }

        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        tableView.tableFooterView = UIView()
        tableView.register(ExercisesHFV.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHFV.reuseIdentifier)
        tableView.register(ProfileTitleTVCell.self,
                           forCellReuseIdentifier: ProfileTitleTVCell.reuseIdentifier)
        tableView.register(ProfileInfoTVCell.self,
                           forCellReuseIdentifier: ProfileInfoTVCell.reuseIdentifier)
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
            tableView.contentInset.bottom = minimizedHeight
        } else {
            tableView.contentInset.bottom = .zero
        }
        UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }

    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = sourceType
            navigationController?.present(imagePickerController, animated: true)
        } else {
            profileTitleTVCell = nil
        }
    }

    @objc private func settingsButtonTapped() {
        Haptic.sendSelectionFeedback()

        let settingsTVC = VCFactory.makeSettingsTVC(style: .grouped)
        let navigationController = MainNC(rootVC: settingsTVC)
        self.navigationController?.present(navigationController, animated: true)
    }
}

// MARK: ListDataSource
extension ProfileTVC: ListDataSource {
    func reloadData() {
        tableView.reloadData()
    }

    func buttonTapped(cell: UITableViewCell, index: Int, function: ButtonFunction) {
        guard let profileTitleTVCell = cell as? ProfileTitleTVCell else {
            return
        }

        self.profileTitleTVCell = profileTitleTVCell
        let alertController = UIAlertController()
        alertController.addAction(UIAlertAction(title: "Camera",
                                                style: .default,
                                                handler: { [weak self] _ in
            self?.getImage(fromSourceType: .camera)
        }))
        alertController.addAction(UIAlertAction(title: "Photo Library",
                                                style: .default,
                                                handler: { [weak self] _ in
            self?.getImage(fromSourceType: .photoLibrary)
        }))

        if function == .update {
            alertController.addAction(UIAlertAction(title: "Remove Photo",
                                                    style: .destructive,
                                                    handler: { [weak self] _ in
                self?.profileTitleTVCell?.update()
                self?.profileTitleTVCell = nil
                self?.customDataSource?.removeProfileImage()
            }))
        }

        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .destructive,
                                                handler: { [weak self] _ in
            self?.profileTitleTVCell = nil
        }))
        navigationController?.present(alertController, animated: true)

    }
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
        tableView.reloadWithoutAnimation()
        renewConstraints()
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileTVC: UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let cell = self?.profileTitleTVCell,
                let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }

            cell.update(image: image)
            self?.customDataSource?.saveProfileImage(image)
            self?.profileTitleTVCell = nil
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        profileTitleTVCell = nil
        picker.dismiss(animated: true)
    }
}
