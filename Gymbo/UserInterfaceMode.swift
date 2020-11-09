//
//  UserInterfaceMode.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
enum UserInterfaceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    static var currentMode: UserInterfaceMode {
        let rawValue = UserDefaults.standard.object(forKey: UserDefaultKeys.INTERFACE_STYLE) as? Int
        return userInterfaceMode(from: rawValue ?? 0)
    }

    var interfaceStyle: UIUserInterfaceStyle {
        let userInterfaceStyle: UIUserInterfaceStyle
        switch self {
        case .system:
            userInterfaceStyle = .unspecified
        case .light:
            userInterfaceStyle = .light
        case .dark:
            userInterfaceStyle = .dark
        }
        return userInterfaceStyle
    }
}

// MARK: - Funcs
extension UserInterfaceMode {
    static func userInterfaceMode(from rawValue: Int) -> UserInterfaceMode {
        let userInterfaceMode: UserInterfaceMode
        switch rawValue {
        case 0:
            userInterfaceMode = .system
        case 1:
            userInterfaceMode = .light
        case 2:
            userInterfaceMode = .dark
        default:
            fatalError("Incorrect raw value of: \(rawValue)")
        }
        return userInterfaceMode
    }

    static func setUserInterfaceMode(with mode: UserInterfaceMode) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.overrideUserInterfaceStyle = mode.interfaceStyle
            UserDefaults.standard.set(mode.interfaceStyle.rawValue, forKey: UserDefaultKeys.INTERFACE_STYLE)
        }
    }
}
