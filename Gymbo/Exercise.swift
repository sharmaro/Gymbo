//
//  Exercise.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

@objcMembers class Exercise: Object, Comparable {
    // Exercise information
    dynamic var name: String?
    dynamic var groups: String?
    dynamic var instructions: String?
    dynamic var tips: String?
    let imageNames = List<String>()
    dynamic var isUserMade = false

    // User-related exercise information
    dynamic var weightType = 0
    dynamic var sets = 1
    let exerciseDetails = List<ExerciseDetails>()

    convenience init(name: String? = nil,
                     groups: String? = nil,
                     instructions: String? = nil,
                     tips: String? = nil,
                     imageNames: List<String> = List<String>(),
                     isUserMade: Bool = false,
                     weightType: Int = 0,
                     sets: Int = 1,
                     exerciseDetails: List<ExerciseDetails> = List<ExerciseDetails>()) {
        self.init()

        self.name = name
        self.weightType = weightType
        self.groups = groups
        self.instructions = instructions
        self.tips = tips

        for imageName in imageNames {
            self.imageNames.append(imageName)
        }

        self.isUserMade = isUserMade

        self.sets = sets
        if exerciseDetails.isEmpty {
            let exerciseDetails = ExerciseDetails()
            self.exerciseDetails.append(exerciseDetails)
        } else {
            for exerciseDetail in exerciseDetails {
                /*
                 Creating a new instance of ExericseDetails so nothing is
                 copied from Realm when adding new sessions
                 */
                let newExerciseDetail = ExerciseDetails(last: exerciseDetail.last,
                                                        reps: exerciseDetail.reps,
                                                        weight: exerciseDetail.weight)
                self.exerciseDetails.append(newExerciseDetail)
            }
        }
    }

    static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        guard let lhsName = lhs.name,
            let rhsName = rhs.name else {
            return false
        }
        return lhsName < rhsName
    }
}
