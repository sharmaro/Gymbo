//
//  CreateEditExerciseTVC+CustomTextViewDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditExerciseTVC: CustomTextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView, cell: UITableViewCell?) {
        textView.animateBorderColorAndWidth(fromColor: .defaultUnselectedBorder,
                                            toColor: .defaultSelectedBorder,
                                            fromWidth: .defaultUnselectedBorder,
                                            toWidth: .defaultSelectedBorder)
    }

    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell?) {
        tableView.performBatchUpdates({
            textView.sizeToFit()
        })

        guard let cell = cell,
              let indexPath = tableView.indexPath(for: cell) else {
            fatalError("Couldn't get indexPath")
        }
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell?) {
        guard let cell = cell,
              let indexPath = tableView.indexPath(for: cell) else {
            fatalError("Couldn't get indexPath")
        }

        let tableRow = customDataSource?.item(at: indexPath)
        let text = textView.text ?? ""
        if tableRow == .instructions {
            customDataSource?.instructions = text
        } else if tableRow == .tips {
            customDataSource?.tips = text
        }

        textView.animateBorderColorAndWidth(fromColor: .defaultSelectedBorder,
                                            toColor: .defaultUnselectedBorder,
                                            fromWidth: .defaultSelectedBorder,
                                            toWidth: .defaultUnselectedBorder)
    }
}
