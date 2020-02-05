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

class SessionDataModel: NSObject {
    // MARK: - Properties
    static let shared = SessionDataModel()

    var sessionsCount: Int? {
        return getSessionsCount()
    }

    private var realm = try? Realm()

    private var sessionsList: Results<Session>?

    // MARK: - NSObject Var/Funcs
    override init() {
        super.init()

        sessionsList = fetchSessions()

        printConfigFileLocation()
    }
}

// MARK: - Funcs
extension SessionDataModel {
    func printConfigFileLocation() {
        print()
        if realm?.configuration.fileURL != nil {
            NSLog("SUCCESS: Realm location exists.")
        } else {
            NSLog("FAILURE: Realm location does not exist.")
        }
        print()
    }

    private func fetchSessions() -> Results<Session>? {
        return realm?.objects(Session.self)
    }

    func addSession(session: Session) {
        try? realm?.write {
            realm?.add(session)
        }
    }

    func removeSessionAtIndex(_ index: Int) {
        guard let list = sessionsList,
            index > -1, index < sessionsList!.count else {
                return
        }
        try? realm?.write {
            realm?.delete(list[index])
        }
    }

    func removeAllRealmData() {
        try? realm?.write {
            realm?.deleteAll()
        }
    }

    func getSession(forIndex index: Int) -> Session? {
        return sessionsList?[index]
    }

    private func getSessionsCount() -> Int {
        return sessionsList?.count ?? 0
    }

    func getSessionName(forIndex index: Int) -> String {
        return sessionsList?[index].name ?? "No name"
    }

    func getExercisesCount(forIndex index: Int) -> Int {
        return sessionsList?[index].exercises.count ?? 0
    }

    func getExerciseInfoList(forSession session: Session) -> [ExerciseInfo]? {
        var exerciseInfoList = [ExerciseInfo]()
        let exercises = session.exercises
        guard exercises.count > 0 else {
                return nil
        }

        for exercise in exercises {
            if let exerciseName = exercise.name, let exerciseMuscles = exercise.muscleGroups {
                exerciseInfoList.append(ExerciseInfo(exerciseName: "\(exercise.sets) x \(exerciseName)", exerciseMuscles: exerciseMuscles))
            }
        }
        return exerciseInfoList
    }

    func sessionInfoText(forIndex index: Int) -> String {
        var sessionInfoText = "No exercises in this session."
        if let exercises = sessionsList?[index].exercises, exercises.count > 0 {
            sessionInfoText = ""
            for i in 0 ..< exercises.count {
                var sessionString = ""
                let name = Util.formattedString(stringToFormat: exercises[i].name, type: .name)
                sessionString = "\(name)"
                if i != exercises.count - 1 {
                    sessionString += ", "
                }
                sessionInfoText.append(sessionString)
            }
        }
        return sessionInfoText
    }
}
