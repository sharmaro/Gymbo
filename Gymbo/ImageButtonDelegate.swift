//
//  ImageButtonDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ImageButtonDelegate: class {
    func buttonTapped(cell: UITableViewCell,
                      index: Int,
                      function: ButtonFunction)
}
