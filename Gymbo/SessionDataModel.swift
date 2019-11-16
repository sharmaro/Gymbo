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
    dynamic var reps: String?
    dynamic var weight: String?
    dynamic var time: String?

    convenience init(reps: String? = nil, weight: String? = nil, time: String? = nil) {
        self.init()
        
        self.reps = reps
        self.weight = weight
        self.time = time
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
