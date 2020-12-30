//
//  SelectionTVC+ListDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension SelectionTVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let customDataSource = customDataSource else {
            return
        }
        Haptic.sendSelectionFeedback()

        let item = customDataSource.item(for: indexPath)
        customDataSource.selectionDelegate?.selected(item: item)
        navigationController?.popViewController(animated: true)
    }
}
