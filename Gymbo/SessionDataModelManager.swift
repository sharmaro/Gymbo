//
//  SessionDataModelManager.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/12/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation
import RealmSwift

class SessionDataModelManager: NSObject {
    // MARK: - Properties
    static var shared = SessionDataModelManager()

    var sessionsCount: Int? {
        return getSessionsCount()
    }

    private var realm = try? Realm()

    private var sessionsList: Results<Session>?

    // MARK: - NSObject Funcs
    override init() {
        super.init()

        sessionsList = fetchSessions()

        printConfigFileLocation()
    }
}

// MARK: - Funcs
extension SessionDataModelManager {
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

    private func isRepsStringUnique(forExercise exercise: Exercise) -> Bool {
        var areUnique = false
        let exerciseDetails = exercise.exerciseDetails
        if exerciseDetails.count == 1 {
            return areUnique
        }

        let reps = exerciseDetails.first?.reps
        for exerciseDetail in exerciseDetails {
            if exerciseDetail.reps != reps {
                areUnique.toggle()
                return areUnique
            }
        }
        return areUnique
    }
}
