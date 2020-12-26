//
//  UIColor+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Init
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

// MARK: - Custom Colors
extension UIColor {
    // Special
    static let defaultSelectedBorder = UIColor.systemGreen
    static let defaultUnselectedBorder = UIColor.dynamicDarkGray
    static let dimmedBackgroundBlack = UIColor.black.withAlphaComponent(0.8)
    static let dimmedDarkGray = UIColor.dynamicDarkGray.withAlphaComponent(0.3)
    static let dimmedLightGray = UIColor.dynamicLightGray.withAlphaComponent(0.3)
    static let disabledBlack = UIColor.black.withAlphaComponent(0.6)

    // Dynamic
    static let dynamicWhite = UIColor(named: "dynamicWhite") ?? .white
    static let dynamicBlack = UIColor(named: "dynamicBlack") ?? .black
    static let dynamicLightGray = UIColor(named: "dynamicLightGray") ?? .gray
    static let dynamicDarkGray = UIColor(named: "dynamicDarkGray") ?? .gray
    static let dynamicDarkTabItem = UIColor(named: "dynamicDarkTabItem") ?? .gray

    // Normal
    static let customBlue = UIColor(rgb: 0x1565C0)
    static let customOrange = UIColor(rgb: 0xFF7400)

    // Light
    static let customLightGray = UIColor(rgb: 0xBDC3C7)

    // Medium
    // Dark
}
