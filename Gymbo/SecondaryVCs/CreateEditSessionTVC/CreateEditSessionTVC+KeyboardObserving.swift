//
//  CreateEditSessionTVC+KeyboardObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: KeyboardObserving {
    // Using didShow and didHide to prevent tableHeaderView flickering on keyboard dismissal
    func keyboardDidShow(_ notification: Notification) {
        guard let keyboardHeight = notification.keyboardSize?.height,
              tableView.numberOfSections > 0 else {
            return
        }
        tableView.contentInset.bottom = keyboardHeight
    }

    func keyboardDidHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}
