//
//  SessionDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/8/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class WorkoutDetails: Object {
    dynamic var reps: String?
    dynamic var weight: String?
    dynamic var time: String?

    convenience init(reps: String? = nil, weight: String? = nil, time: String? = nil) {
        self.init()
        
        self.reps = reps
        self.weight = weight
        self.time = time
    }

    func printInfo() {
        print("reps: \(reps ?? "")")
        print("weight: \(weight ?? "")")
        print("time: \(time ?? "")")
    }
}

@objcMembers class Workout: Object {
    dynamic var name: String?
    dynamic var muscleGroups: String?
    dynamic var sets: Int = 1
    dynamic var additionalInfo: String?
    let workoutDetails = List<WorkoutDetails>()

    convenience init(name: String? = nil, muscleGroups: String? = nil, sets: Int = 1, additionalInfo: String? = nil, workoutDetails: List<WorkoutDetails>) {
        self.init()

        self.name = name
        self.muscleGroups = muscleGroups
        self.sets = sets
        self.additionalInfo = additionalInfo

        if workoutDetails.count == 0 {
            let workoutDetail = WorkoutDetails()
            self.workoutDetails.append(workoutDetail)
        } else {
            for workoutDetail in workoutDetails {
                self.workoutDetails.append(workoutDetail)
            }
        }
    }
}

@objcMembers class Session: Object {
    dynamic var name: String?
    let workouts = List<Workout>()

    convenience init(name: String? = nil, workouts: List<Workout>) {
        self.init()
        
        self.name = name

        for workout in workouts {
            self.workouts.append(workout)
        }
    }
}
