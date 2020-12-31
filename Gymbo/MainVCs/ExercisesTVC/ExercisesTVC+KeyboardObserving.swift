//
//  ExercisesTVC+KeyboardObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension ExercisesTVC: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = notification.keyboardSize?.height,
              tableView.numberOfSections > 0 else {
            return
        }
        tableView.contentInset.bottom = keyboardHeight
    }

    func keyboardWillHide(_ notification: Notification) {
        tableView.contentInset = .zero
    }
}
