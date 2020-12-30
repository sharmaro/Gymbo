//
//  StartSessionTVC+ListDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartSessionTVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let exerciseDetailCell = tableView
                .cellForRow(at: indexPath) as? ExerciseDetailTVCell else {
            return
        }
        customDataSource?.didSelect(cell: exerciseDetailCell, at: indexPath)
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        customDataSource?.heightForRow(at: indexPath) ?? 0
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfiguration indexPath: IndexPath) {
        customDataSource?.removeSet(in: tableView, indexPath: indexPath)
    }
}
