//
//  Transform.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

enum Transform {
    case shrink
    case inflate

    static func caseFromBool(bool: Bool) -> Transform {
        bool ? .shrink : .inflate
    }
}
