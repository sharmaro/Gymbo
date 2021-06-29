//
//  StartedSessionTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StartedSessionTVD: NSObject {
    private weak var listDelegate: ListDelegate?

    var session: Session?

    init(listDelegate: ListDelegate?) {
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension StartedSessionTVD {
    enum Constants {
        static let headerHeight = CGFloat(40)
    }
}

// MARK: - UITableViewDelegate
extension StartedSessionTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? .leastNonzeroMagnitude : Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? .leastNonzeroMagnitude : Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
                   didSelectRowAt indexPath: IndexPath) {
        listDelegate?.didSelectItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   didDeselectRowAt indexPath: IndexPath) {
        listDelegate?.didDeselectItem(at: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt
                    indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, completion in
            Haptic.sendImpactFeedback(.medium)
            self?.listDelegate?.tableView(tableView,
                                          trailingSwipeActionsConfiguration: indexPath)

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
