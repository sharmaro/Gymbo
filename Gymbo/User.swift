//
//  User.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

struct User {
    static var isFirstLoad: Bool {
        return (UserDefaults.standard.object(forKey: UserDefaultKeys.IS_FIRST_LOAD) as? Bool) ?? true
    }

    static func firstTimeLoaded() {
        UserDefaults.standard.set(false, forKey: UserDefaultKeys.IS_FIRST_LOAD)
    }
}
