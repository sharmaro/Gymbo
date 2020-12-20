//
//  CustomTextFieldDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol CustomTextFieldDelegate: class {
    func textFieldEditingChanged(textField: UITextField)
    func textFieldEditingDidEnd(textField: UITextField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

extension CustomTextFieldDelegate {
    func textFieldEditingChanged(textField: UITextField) {}
    func textFieldEditingDidEnd(textField: UITextField) {}
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { true }
}
