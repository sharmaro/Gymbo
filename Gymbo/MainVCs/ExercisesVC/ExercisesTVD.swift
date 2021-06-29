//
//  ExercisesTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class ExercisesTVD: NSObject {
    private var sectionTitles: [String] {
        Array(realm?.objects(ExercisesList.self).first?.sectionTitles ?? List<String>())
    }

    private var realm: Realm? {
        try? Realm()
    }

    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension ExercisesTVD {
    enum Constants {
        static let headerHeight = CGFloat(40)
        static let exerciseCellHeight = CGFloat(70)
    }
}

// MARK: - Funcs
extension ExercisesTVD {
    private func titleForHeaderIn(section: Int) -> String {
        sectionTitles[section]
    }
}

// MARK: - UITableViewDelegate
extension ExercisesTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        tableView.numberOfSections == 1 ? 0 : Constants.headerHeight
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        tableView.numberOfSections == 1 ? 0 : Constants.headerHeight
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ExercisesHFV.reuseIdentifier) as? ExercisesHFV else {
            return nil
        }

        let title = titleForHeaderIn(section: section)
        headerView.configure(title: title)
        return headerView
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.exerciseCellHeight
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.exerciseCellHeight
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
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
        -> UISwipeActionsConfiguration? {
        guard tableView.cellForRow(at: indexPath) is ExerciseTVCell else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Delete") { [weak self] _, _, completion in
            Haptic.sendImpactFeedback(.medium)

            self?.listDelegate?
                .tableView(tableView, trailingSwipeActionsConfiguration: indexPath)
            if tableView.numberOfRows(inSection: indexPath.section) > 1 {
                tableView.reloadSections([indexPath.section], with: .fade)
            } else {
                tableView.deleteSections([indexPath.section], with: .automatic)
            }
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
