//
//  Exercise.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class Exercise: Object, Comparable {
    // Exercise information
    dynamic var name: String?
    dynamic var groups: String?
    dynamic var instructions: String?
    dynamic var tips: String?
    let imagesData = List<Data>()
    dynamic var isUserMade = false

    // User-related exercise information
    dynamic var sets: Int = 1
    let exerciseDetails = List<ExerciseDetails>()

    convenience init(name: String? = nil, groups: String? = nil, instructions: String? = nil, tips: String? = nil, imagesData: List<Data> = List<Data>(), isUserMade: Bool = false, sets: Int = 1, exerciseDetails: List<ExerciseDetails> = List<ExerciseDetails>()) {
        self.init()

        self.name = name
        self.groups = groups
        self.instructions = instructions
        self.tips = tips
        for imageData in imagesData {
            self.imagesData.append(imageData)
        }
        self.isUserMade = isUserMade

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

    static func < (lhs: Exercise, rhs: Exercise) -> Bool {
        guard let lhsName = lhs.name,
            let rhsName = rhs.name else {
            return false
        }
        return lhsName < rhsName
    }
}
