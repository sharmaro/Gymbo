//
//  CALayer+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CALayer {
    func addCorner(style: CornerStyle) {
        masksToBounds = true
        cornerRadius = style.radius
    }

    func removeCorners() {
        cornerRadius = 0
    }

    func roundTopCorners(style: CornerStyle) {
        addCorner(style: style)
        let maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.maskedCorners = maskedCorners
    }

    func roundBottomCorners(style: CornerStyle) {
        addCorner(style: style)
        let maskedCorners: CACornerMask = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.maskedCorners = maskedCorners
    }
}
