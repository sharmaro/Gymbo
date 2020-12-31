//
//  StartedSessionTVC+ButtonTVCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartedSessionTVC: ButtonTVCellDelegate {
    func buttonTapped(cell: ButtonTVCell) {
        guard let section = tableView.indexPath(for: cell)?.section,
              let session = customDataSource?.session else {
            return
        }
        Haptic.sendImpactFeedback(.medium)

        customDataSource?.addSet(at: section)
        DispatchQueue.main.async { [weak self] in
            let sets = session.exercises[section].sets
            let lastIndexPath = IndexPath(row: sets, section: section)

            // Using .none because the animation doesn't work well with this VC
            self?.tableView.insertRows(at: [lastIndexPath], with: .none)
            // Scrolling to addSetButton row
            let indexPath = IndexPath(row: sets + 1, section: section)
            self?.tableView.scrollToRow(at: indexPath,
                                        at: .none,
                                        animated: true)
        }
    }
}
