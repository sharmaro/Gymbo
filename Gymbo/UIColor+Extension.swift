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
    static let defaultUnselectedBorder = UIColor.mainDarkGray
    static let dimmedBackgroundBlack = UIColor.black.withAlphaComponent(0.8)
    static let dimmedDarkGray = UIColor.mainDarkGray.withAlphaComponent(0.2)
    static let dimmedLightGray = UIColor.mainLightGray.withAlphaComponent(0.2)

    // Main
    static let mainWhite = UIColor(named: "mainWhite") ?? .white
    static let mainBlack = UIColor(named: "mainBlack") ?? .black
    static let mainLightGray = UIColor(named: "mainLightGray") ?? .gray
    static let mainDarkGray = UIColor(named: "mainDarkGray") ?? .gray

    // Normal
    static let customBlue = UIColor(rgb: 0x1565C0)
    static let customPeach = UIColor(rgb: 0xF7797D)
    static let customRed = UIColor(rgb: 0xB92B27)

    // Light
    static let customLightBlue = UIColor(rgb: 0x6DD5ED)
    static let customLightGray = UIColor(rgb: 0xBDC3C7)
    static let customLightGreen = UIColor(rgb: 0x99F2C8)
    static let customLightPurple = UIColor(rgb: 0x8E2DE2)
    static let customLightYellow = UIColor(rgb: 0xFBD786)

    // Medium

    // Dark
    static let customDarkBlue = UIColor(rgb: 0x2193B0)
    static let customDarkGray = UIColor(rgb: 0x2C3E50)
    static let customDarkGreen = UIColor(rgb: 0x1F4037)
    static let customDarkPurple = UIColor(rgb: 0x4A00E0)
}
