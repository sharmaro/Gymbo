//
//  RealmInstance.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/24/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmInstance {
    static var realm: Realm? {
        try? Realm()
    }
}
