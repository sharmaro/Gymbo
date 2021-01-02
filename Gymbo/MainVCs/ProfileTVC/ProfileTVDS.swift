//
//  ProfileTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class ProfileTVDS: NSObject {
    private(set)var user: User?

    private let items: [[Item]] = [
        [.profileTitle],
        [.firstName, .lastName, .age, .weight, .height]
    ]

    private var realm: Realm? {
        try? Realm()
    }

    private let defaultImage = UIImage(named: "add") ?? UIImage()

    private var userImage: UIImage {
        let image = Utility.getImageFrom(name: user?.profileImageName ?? "",
                                         directory: .profileImage)
        return image ?? defaultImage
    }

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?, user: User?) {
        self.user = user
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension ProfileTVDS {
    private struct Constants {
    }

    enum Item: String {
        case profileTitle
        case firstName = "First Name"
        case lastName = "Last Name"
        case age = "Age"
        case weight = "Weight (lbs)"
        case height = "Height (ft'in)"

        var keyboardType: UIKeyboardType {
            let type: UIKeyboardType
            switch self {
            case .firstName, .lastName, .height:
                type = .alphabet
            case .age:
                type = .numberPad
            case .weight:
                type = .decimalPad
            default:
                type = .alphabet
            }
            return type
        }
    }
}

// MARK: - Funcs
extension ProfileTVDS {
    private func getProfileTitleTVCell(in tableView: UITableView,
                                       for indexPath: IndexPath) -> ProfileTitleTVCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileTitleTVCell.reuseIdentifier,
                for: indexPath) as? ProfileTitleTVCell else {
            fatalError("Could not dequeue \(ProfileTitleTVCell.reuseIdentifier)")
        }

        let firstName = user?.firstName ?? "Me"
        let lastName = user?.lastName ?? ""
        let totalSessions = "\(user?.allSessions.count ?? 0) total | "
        let canceledSessions = "\(user?.canceledSessions.count ?? 0) canceled | "
        let finishedSessions = "\(user?.finishedSessions.count ?? 0) finished"
        let description = "\(totalSessions)\(canceledSessions)\(finishedSessions)"
        cell.configure(image: userImage,
                            name: "\(firstName) \(lastName)",
                            description: description)
        cell.imageButtonDelegate = self
        return cell
    }

    private func getProfileInfoTVCell(in tableView: UITableView,
                                      for indexPath: IndexPath) -> ProfileInfoTVCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileInfoTVCell.reuseIdentifier,
                for: indexPath) as? ProfileInfoTVCell else {
            fatalError("Could not dequeue \(ProfileInfoTVCell.reuseIdentifier)")
        }

        let item = items[indexPath.section][indexPath.row]
        let rightText = self.rightText(for: item)
        cell.configure(leftText: item.rawValue,
                           rightText: rightText,
                           keyboardType: item.keyboardType,
                           row: indexPath.row)
        cell.customTextFieldDelegate = self
        return cell
    }

    func rightText(for item: Item) -> String {
        let response: String
        switch item {
        case .firstName:
            response = user?.firstName ?? ""
        case .lastName:
            response = user?.lastName ?? ""
        case .age:
            response = user?.age ?? ""
        case .weight:
            response = user?.weight ?? ""
        case .height:
            response = user?.height ?? ""
        default:
            response = ""
        }
        return response
    }

    func saveProfileImage(_ image: UIImage) {
        let imageName = Utility.saveImages(name: "user_image",
                                           images: [image],
                                           isUserMade: true,
                                           directory: .profileImage) ?? [""]
        try? realm?.write {
            user?.profileImageName = imageName.first
        }
    }

    func removeProfileImage() {
        Utility.removeImage(name: user?.profileImageName ?? "",
                            directory: .profileImage)
    }
}

// MARK: - UITableViewDataSource
extension ProfileTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section][indexPath.row]
        let cell: UITableViewCell
        switch item {
        case .profileTitle:
            cell = getProfileTitleTVCell(in: tableView, for: indexPath)
        case .firstName, .lastName, .age, .weight, .height:
            cell = getProfileInfoTVCell(in: tableView, for: indexPath)
        }
        return cell
    }
}

// MARK: - CustomTextFieldDelegate
extension ProfileTVDS: CustomTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldEditingDidEnd(textField: UITextField) {
        guard let text = textField.text, !text.isEmpty else {
            return
        }

        let realm = try? Realm()
        try? realm?.write {
            switch textField.tag {
            case 0: // First Name
                user?.firstName = text
                listDataSource?.reloadData()
            case 1: // Last Name
                user?.lastName = text
                listDataSource?.reloadData()
            case 2: // Age
                guard text.count < 4 else {
                    return
                }
                user?.age = text
            case 3: // Weight
                guard text.count < 4 else {
                    return
                }
                user?.weight = text
            case 4: // Height
                guard text.count < 5 else {
                    return
                }
                user?.height = text
            default:
                return
            }
        }
    }
}

// MARK: - ImageButtonDelegate
extension ProfileTVDS: ImageButtonDelegate {
    func buttonTapped(cell: UITableViewCell, index: Int, function: ButtonFunction) {
        listDataSource?.buttonTapped(cell: cell,
                                     index: index,
                                     function: function)
    }
}
