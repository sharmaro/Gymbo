//
//  StartedSession.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/24/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class StartedSession: Object {
    dynamic var name: String?
    dynamic var info: String?
    let selectedRows = List<RealmIndexPath>()
    let exercises = List<Exercise>()

    convenience init(name: String? = nil,
                     info: String? = nil,
                     selectedRows: List<RealmIndexPath>,
                     exercises: List<Exercise>) {
        self.init()

        self.name = name
        self.info = info

        for selectedRow in selectedRows {
            self.selectedRows.append(selectedRow)
        }

        for exercise in exercises {
            self.exercises.append(exercise)
        }
    }
}
