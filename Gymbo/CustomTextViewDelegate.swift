//
//  CustomTextViewDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol CustomTextViewDelegate: class {
    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell?)
    func textViewDidBeginEditing(_ textView: UITextView, cell: UITableViewCell?)
    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell?)
}

extension CustomTextViewDelegate {
    func textViewDidChange(_ textView: UITextView, cell: UITableViewCell?) {}
    func textViewDidBeginEditing(_ textView: UITextView, cell: UITableViewCell?) {}
    func textViewDidEndEditing(_ textView: UITextView, cell: UITableViewCell?) {}
}
