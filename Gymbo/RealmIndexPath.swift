//
//  RealmIndexPath.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/24/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class RealmIndexPath: Object {
    dynamic var section: String?
    dynamic var row: String?

    var indexPath: IndexPath {
        IndexPath(row: Int(row ?? "0") ?? 0,
                  section: Int(section ?? "0") ?? 0)
    }

    convenience init(indexPath: IndexPath) {
        self.init()

        self.section = String(indexPath.section)
        self.row = String(indexPath.row)
    }
}
