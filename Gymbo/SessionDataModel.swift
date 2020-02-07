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

extension Session: NSItemProviderReading {
    static var readableTypeIdentifiersForItemProvider: [String] {
        return []
    }

    static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> Self {
        return self.init()
    }
}

extension Session: NSItemProviderWriting {
    static var writableTypeIdentifiersForItemProvider: [String] {
        return []
    }

    func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        return nil
    }
}

@objcMembers class SessionsList: Object {
    let sessions = List<Session>()
}

class SessionDataModel: NSObject {
    // MARK: - Properties
    static let shared = SessionDataModel()

    var count: Int {
        return sessionsCount()
    }

    private var realm = try? Realm()

    private var sessionsList: SessionsList?

    // MARK: - NSObject Var/Funcs
    override init() {
        super.init()

        sessionsList = fetchSessions()
        printConfigFileLocation()
    }
}

// MARK: - Funcs
extension SessionDataModel {
    private func printConfigFileLocation() {
        print()
        if realm?.configuration.fileURL != nil {
            NSLog("SUCCESS: Realm location exists.")
        } else {
            NSLog("FAILURE: Realm location does not exist.")
        }
        print()
    }

    private func fetchSessions() -> SessionsList? {
        return realm?.objects(SessionsList.self).first
    }

    private func sessionsCount() -> Int {
        return sessionsList?.sessions.count ?? 0
    }

    private func removeAllRealmData() {
        try? realm?.write {
            realm?.deleteAll()
        }
    }

    private func check(index: Int) -> SessionsList {
        guard let list = sessionsList,
            index > -1,
            index < list.sessions.count else {
                fatalError("Can't interact with session at index \(index)")
        }
        return list
    }

    func session(for index: Int) -> Session? {
        return sessionsList?.sessions[index]
    }

    func sessionName(for index: Int) -> String {
        return sessionsList?.sessions[index].name ?? "No name"
    }

    func exercisesCount(for index: Int) -> Int {
        return sessionsList?.sessions[index].exercises.count ?? 0
    }

    func exerciseInfoList(for session: Session) -> [ExerciseInfo]? {
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

    func sessionInfoText(for index: Int) -> String {
        var sessionInfoText = "No exercises in this session."
        if let exercises = sessionsList?.sessions[index].exercises, exercises.count > 0 {
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

    func add(session: Session) {
        if let list = sessionsList {
            try? realm?.write {
                list.sessions.append(session)
            }
        } else {
            let list = SessionsList()
            list.sessions.append(session)
            try? realm?.write {
                realm?.add(list)
            }
            sessionsList = list
        }
    }

    func insert(session: Session, at index: Int) {
        // Can insert into array at an index that's 1 + array.count
        guard let list = sessionsList, index > -1,
            index < list.sessions.count + 1 else {
                fatalError("Can't insert session at index \(index)")
        }

        try? realm?.write {
            list.sessions.insert(session, at: index)
        }
    }

    func replace(at index: Int, with session: Session) {
        let list = check(index: index)

        try? realm?.write {
            list.sessions[index] = session
        }
    }

    func remove(at index: Int) {
        let list = check(index: index)

        try? realm?.write {
            list.sessions.remove(at: index)
        }
    }
}
