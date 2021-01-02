//
//  Session.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class Session: Object {
    dynamic var name: String?
    dynamic var info: String?
    var exercises = List<Exercise>()

    // Useful info
    dynamic var sessionSeconds: Int = 0
    dynamic var dateCompleted: Date?

    // Helpers
    var safeCopy: Session {
        let exercises = List<Exercise>()
        for exercise in self.exercises {
            exercises.append(exercise.safeCopy)
        }
        return Session(name: name, info: info, exercises: exercises)
    }

    var totalWeight: Int {
        var totalCount = 0
        for exercise in exercises {
            // kg
            if exercise.weightType == 1 {
                totalCount += (exercise.totalWeight * 2)
            } else {
                totalCount += exercise.totalWeight
            }
        }
        return totalCount
    }

    convenience init(name: String? = nil, info: String? = nil, exercises: List<Exercise>) {
        self.init()

        self.name = name
        self.info = info

        for exercise in exercises {
            self.exercises.append(exercise)
        }
    }
}

// MARK: - For Dragging and Dropping Cells

// MARK: - NSItemProviderReading
extension Session: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        []
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        self.init()
    }
}

// MARK: - NSItemProviderWriting
extension Session: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        []
    }

    func loadData(withTypeIdentifier typeIdentifier: String,
                  forItemProviderCompletionHandler completionHandler:
        @escaping (Data?, Error?) -> Void) -> Progress? {
        nil
    }
}
