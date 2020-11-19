//
//  TextViewTableViewCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol TextViewTableViewCellDelegate: class {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell)
    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell)
}

extension TextViewTableViewCellDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {}
    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell) {}
    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell) {}
}
