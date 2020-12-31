//
//  CreateEditSessionTVC+CustomTextViewDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: CustomTextViewDelegate {
    private struct Constants {
        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "Info"
    }

    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell?) {
        tableView.performBatchUpdates({
            textView.sizeToFit()
        })
    }

    func textViewDidBeginEditing(_ textView: UITextView, cell: UITableViewCell?) {
        if textView.textColor == .dimmedDarkGray {
            textView.text.removeAll()
            textView.textColor = .dynamicBlack
        }
    }

    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell?) {
        if textView.text.isEmpty {
            let name = customDataSource?.session.name
            let info = customDataSource?.session.info
            let textInfo = [name, info]

            if let text = textInfo[textView.tag] {
                textView.text = text
                textView.textColor = .dynamicBlack
            } else {
                textView.text = textView.tag == 0 ?
                    Constants.namePlaceholderText : Constants.infoPlaceholderText
                textView.textColor = .dimmedDarkGray
            }
            return
        }
    }
}
