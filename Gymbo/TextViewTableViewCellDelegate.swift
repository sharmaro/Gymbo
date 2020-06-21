//
//  TextViewTableViewCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol TextViewTableViewCellDelegate: class {
    func textViewDidChange(_ textView: UITextView, cell: TextViewTableViewCell)
}
