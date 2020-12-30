//
//  ListDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ListDelegate: class {
    func didSelectItem(at indexPath: IndexPath)
    func didDeselectItem(at indexPath: IndexPath)
    func heightForRow(at indexPath: IndexPath) -> CGFloat
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfiguration indexPath: IndexPath)
}

extension ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {}
    func didDeselectItem(at indexPath: IndexPath) {}
    func heightForRow(at indexPath: IndexPath) -> CGFloat { 0 }
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfiguration indexPath: IndexPath) {}
}
