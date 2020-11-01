//
//  User.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

// MARK: - Properties
struct User {
}

// MARK: - Funcs
extension User {
    static var isFirstTimeLoad: Bool {
        return (UserDefaults.standard.object(forKey: UserDefaultKeys.IS_FIRST_TIME_LOAD) as? Bool) ?? true
    }

    static func firstTimeLoadComplete() {
        UserDefaults.standard.set(false, forKey: UserDefaultKeys.IS_FIRST_TIME_LOAD)
    }
}
