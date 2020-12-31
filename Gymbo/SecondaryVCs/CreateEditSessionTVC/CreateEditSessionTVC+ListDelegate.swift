//
//  CreateEditSessionTVC+ListDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: ListDelegate {
    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        customDataSource?.heightForRow(at: indexPath) ?? 0
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfiguration indexPath: IndexPath) {
        view.endEditing(true)
        customDataSource?.deleteSetRealm(indexPath: indexPath)
    }
}
