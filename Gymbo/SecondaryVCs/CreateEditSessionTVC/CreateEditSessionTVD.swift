//
//  CreateEditSessionTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class CreateEditSessionTVD: NSObject {
    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension CreateEditSessionTVD {
    struct Constants {
        static let exerciseHeaderCellHeight = CGFloat(67)
        static let exerciseDetailCellHeight = CGFloat(40)
        static let buttonCellHeight = CGFloat(65)
    }
}

// MARK: - Funcs
extension CreateEditSessionTVD {}

// MARK: - UITableViewDelegate
extension CreateEditSessionTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return Constants.exerciseHeaderCellHeight
        case tableView.numberOfRows(inSection: indexPath.section) - 1:
            return Constants.buttonCellHeight
        default:
            return Constants.exerciseDetailCellHeight
        }
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return Constants.exerciseHeaderCellHeight
        case tableView.numberOfRows(inSection: indexPath.section) - 1:
            return Constants.buttonCellHeight
        default:
            return Constants.exerciseDetailCellHeight
        }
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Calls text field and text view didEndEditing() and saves data
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, completion in
            Haptic.sendImpactFeedback(.medium)
            self?.listDelegate?.tableView(tableView, trailingSwipeActionsConfiguration: indexPath)

            tableView.performBatchUpdates({
                tableView.deleteRows(at: [indexPath], with: .automatic)
                // Reloading section so the set indices can update
                tableView.reloadSections([indexPath.section], with: .automatic)
            })
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
