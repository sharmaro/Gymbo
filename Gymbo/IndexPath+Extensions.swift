//
//  IndexPath+Extensions.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/24/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

extension IndexPath {
    var realmIndex: RealmIndexPath {
        RealmIndexPath(indexPath: self)
    }
}
