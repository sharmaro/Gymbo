//
//  SessionDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/8/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class SessionDataModel: NSObject {
    private var realm: Realm? {
        try? Realm()
    }

    private var sessionsList: SessionsList? {
        realm?.objects(SessionsList.self).first
    }

    var count: Int {
        sessionsList?.sessions.count ?? 0
    }

    var isEmpty: Bool {
        sessionsList?.sessions.isEmpty ?? true
    }

    weak var dataFetchDelegate: DataFetchDelegate?
}

// MARK: - Funcs
extension SessionDataModel {
    // Delete this eventually
    private func printConfigFileLocation() {
        realm?.configuration.fileURL != nil ?
            NSLog("SUCCESS: Realm location exists.") :
            NSLog("FAILURE: Realm location does not exist.")
        print("\(String(describing: realm?.configuration.fileURL))\n")
    }

    func fetchData() {
        printConfigFileLocation()
        dataFetchDelegate?.didBeginFetch()

        // Add a sample session for first time downloads
        if User.isFirstTimeLoad {
            let sampleExercise = Exercise(name: "Sample Exercise",
                                          groups: "sample groups",
                                          instructions: "Sample Instructions",
                                          tips: "Sample Tips",
                                          isUserMade: false,
                                          weightType: WeightType.lbs.rawValue)
            let sampleExerciseList = List<Exercise>()
            sampleExerciseList.append(sampleExercise)
            let sampleSession = Session(name: "Sample", info: "Sample Info", exercises: sampleExerciseList)

            let list = SessionsList()
            list.sessions.append(sampleSession)
            try? realm?.write {
                realm?.add(list)
            }
        }
        dataFetchDelegate?.didEndFetch()
    }

    private func removeAllRealmData() {
        try? realm?.write {
            realm?.deleteAll()
        }
    }

    private func check(_ index: Int) -> SessionsList {
        guard let list = sessionsList,
            index > -1,
            index < list.sessions.count else {
                fatalError("Can't interact with session at index \(index)")
        }
        return list
    }

    func index(of name: String) -> Int? {
        sessionsList?.sessions.firstIndex(where: {
            $0.name == name
        })
    }

    func session(for index: Int) -> Session? {
        sessionsList?.sessions[index]
    }

    func sessionName(for index: Int) -> String {
        sessionsList?.sessions[index].name ?? "No name"
    }

    func exercisesCount(for index: Int) -> Int {
        sessionsList?.sessions[index].exercises.count ?? 0
    }

    func sessionInfoText(for index: Int) -> String {
        var sessionInfoText = "No exercises in this session."
        if let exercises = sessionsList?.sessions[index].exercises,
            !exercises.isEmpty {
            sessionInfoText = ""
            for i in 0 ..< exercises.count {
                var sessionString = ""
                let name = Utility.formattedString(stringToFormat: exercises[i].name, type: .name)
                sessionString = "\(name)"
                if i != exercises.count - 1 {
                    sessionString += ", "
                }
                sessionInfoText.append(sessionString)
            }
        }
        return sessionInfoText
    }

    func create(session: Session, completion: @escaping(Result<Any?, DataError>) -> Void) {
        guard let list = sessionsList,
            !list.sessions.contains(where: {
            $0.name == session.name
        }) else {
            completion(.failure(.createFail))
            return
        }

        try? realm?.write {
            list.sessions.append(session)
            completion(.success(nil))
        }
    }

    func update(_ currentName: String,
                session: Session,
                completion: @escaping(Result<Any?, DataError>) -> Void) {
        guard let newName = session.name,
            let index = index(of: currentName) else {
            completion(.failure(.updateFail))
            return
        }

        if currentName == newName {
            try? realm?.write {
                sessionsList?.sessions[index] = session
                completion(.success(nil))
            }
        } else {
            guard self.index(of: newName) == nil else {
                completion(.failure(.updateFail))
                return
            }

            try? realm?.write {
                sessionsList?.sessions.remove(at: index)
                sessionsList?.sessions.append(session)
                completion(.success(nil))
            }
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
        let list = check(index)

        try? realm?.write {
            list.sessions[index] = session
        }
    }

    func remove(at index: Int) {
        let list = check(index)

        try? realm?.write {
            list.sessions.remove(at: index)
        }
    }

    func removeInstancesOfExercise(name: String?) {
        guard let name = name else {
            return
        }

        if let sessions = sessionsList?.sessions {
            for session in sessions {
                let exercises = session.exercises
                if let index = exercises.firstIndex(where: {
                    $0.name == name
                }) {
                    try? realm?.write {
                        exercises.remove(at: index)
                    }
                }
            }
        }
    }
}
