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
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension CreateEditSessionTVD {
    struct Constants {
        static let headerHeight = CGFloat(40)
    }
}

// MARK: - UITableViewDelegate
extension CreateEditSessionTVD: UITableViewDelegate {
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
        listDelegate?.heightForRow(at: indexPath) ?? 0
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        listDelegate?.heightForRow(at: indexPath) ?? 0
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
