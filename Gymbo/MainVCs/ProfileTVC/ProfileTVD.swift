//
//  ProfileTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileTVD: NSObject {
    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
extension ProfileTVD {
    private struct Constants {
    }
}

// MARK: - Funcs
extension ProfileTVD {
}

// MARK: - UITableViewDelegate
extension ProfileTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        0
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        listDelegate?.didSelectItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        listDelegate?.didDeselectItem(at: indexPath)
    }
}
