//
//  Gradient.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

struct Gradient {
    var startingColor: UIColor
    var endingColor: UIColor

    var colors: [UIColor] {
        [startingColor, endingColor]
    }
}
