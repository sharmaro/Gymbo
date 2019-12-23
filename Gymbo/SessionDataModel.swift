//
//  SessionDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/8/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class ExerciseDetails: Object {
    dynamic var last: String?
    dynamic var reps: String?
    dynamic var weight: String?

    convenience init(last: String? = nil, reps: String? = nil, weight: String? = nil) {
        self.init()

        self.last = last
        self.reps = reps
        self.weight = weight
    }
}

@objcMembers class Exercise: Object {
    dynamic var name: String?
    dynamic var muscleGroups: String?
    dynamic var sets: Int = 1
    let exerciseDetails = List<ExerciseDetails>()

    convenience init(name: String? = nil, muscleGroups: String? = nil, sets: Int = 1, exerciseDetails: List<ExerciseDetails>) {
        self.init()

        self.name = name
        self.muscleGroups = muscleGroups
        self.sets = sets

        if exerciseDetails.isEmpty {
            let exerciseDetails = ExerciseDetails()
            self.exerciseDetails.append(exerciseDetails)
        } else {
            for exerciseDetail in exerciseDetails {
                self.exerciseDetails.append(exerciseDetail)
            }
        }
    }
}

@objcMembers class Session: Object {
    dynamic var name: String?
    dynamic var info: String?
    let exercises = List<Exercise>()

    convenience init(name: String? = nil, info: String? = nil, exercises: List<Exercise>) {
        self.init()

        self.name = name
        self.info = info

        for exercise in exercises {
            self.exercises.append(exercise)
        }
    }
}
