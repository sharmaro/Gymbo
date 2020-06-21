//
//  TextFieldTableViewCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol TextFieldTableViewCellDelegate: class {
    func textFieldEditingChanged(textField: UITextField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

extension TextFieldTableViewCellDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
