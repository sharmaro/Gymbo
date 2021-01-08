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
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension ProfileTVD {
    struct Constants {
        static let headerHeight = CGFloat(40)
        static let titleCellHeight = CGFloat(100)
        static let infoCellHeight = CGFloat(50)
    }
}

// MARK: - Funcs
extension ProfileTVD {
    private func heightFor(section: Int) -> CGFloat {
        let height: CGFloat
        switch section {
        case 0:
            height = Constants.titleCellHeight
        default:
            height = Constants.infoCellHeight
        }
        return height
    }
}

// MARK: - UITableViewDelegate
extension ProfileTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? .leastNonzeroMagnitude : Constants.headerHeight
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? .leastNonzeroMagnitude : Constants.headerHeight
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard section > 0,
              let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ExercisesHFV.reuseIdentifier) as? ExercisesHFV else {
            return nil
        }
        return headerView
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        heightFor(section: indexPath.section)
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        heightFor(section: indexPath.section)
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
