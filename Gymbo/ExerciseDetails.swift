//
//  ExerciseDetails.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class ExerciseDetails: Object {
    dynamic var last: String?
    dynamic var reps: String?
    dynamic var weight: String?

    // Helpers
    var totalWeight: Int {
        let reps = Int(self.reps ?? "0") ?? 0
        let weight = Int(self.weight ?? "0") ?? 0
        return reps * weight
    }

    convenience init(last: String? = nil, reps: String? = nil, weight: String? = nil) {
        self.init()

        self.last = last
        self.reps = reps
        self.weight = weight
    }
}
