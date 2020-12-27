//
//  User.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class User: Object {
    dynamic var isFirstTimeLoad = true
    let canceledExercises = List<Exercise>()
    let finishedExercises = List<Exercise>()

    convenience init(isFirstTimeLoad: Bool = true,
                     canceledExercises: List<Exercise> = List<Exercise>(),
                     finishedExercises: List<Exercise> = List<Exercise>()) {
        self.init()

        for exercise in canceledExercises {
            self.canceledExercises.append(exercise)
        }

        for exercise in finishedExercises {
            self.finishedExercises.append(exercise)
        }
    }
}
