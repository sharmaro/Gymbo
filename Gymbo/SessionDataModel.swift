//
//  SessionDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/8/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import RealmSwift

protocol SessionDataModelDelegate: class {
    func create(_ session: Session, success: @escaping(() -> Void), fail: @escaping(() -> Void))
    func update(_ currentName: String, session: Session, success: @escaping(() -> Void), fail: @escaping(() -> Void))
}

extension SessionDataModelDelegate {
    func create(_ session: Session, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
    func update(_ currentName: String, session: Session, success: @escaping(() -> Void), fail: @escaping(() -> Void)) {}
}

// MARK: - Properties
class SessionDataModel: NSObject {
    static let shared = SessionDataModel()

    private var realm = try? Realm()
    private var sessionsList: SessionsList?

    var count: Int {
        return sessionsList?.sessions.count ?? 0
    }

    var isEmpty: Bool {
        return sessionsList?.sessions.isEmpty ?? true
    }

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
        print(String(describing: realm?.configuration.fileURL))
        print()
    }

    private func fetchSessions() -> SessionsList? {
        return realm?.objects(SessionsList.self).first
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
        return sessionsList?.sessions.firstIndex(where: {
            name == $0.name
        })
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

    func sessionInfoText(for index: Int) -> String {
        var sessionInfoText = "No exercises in this session."
        var exercisesToRemove = [String]()

        if let exercises = sessionsList?.sessions[index].exercises,
            !exercises.isEmpty {
            sessionInfoText = ""
            for i in 0 ..< exercises.count {
                if ExerciseDataModel.shared.doesExerciseExist(name: exercises[i].name ?? "") {
                    var sessionString = ""
                    let name = Util.formattedString(stringToFormat: exercises[i].name, type: .name)
                    sessionString = "\(name)"
                    if i != exercises.count - 1 {
                        sessionString += ", "
                    }
                    sessionInfoText.append(sessionString)
                } else {
                    exercisesToRemove.append(exercises[i].name ?? "")
                }
            }

            exercisesToRemove.forEach {
                let name = $0
                if let firstIndex = exercises.firstIndex(where: { (exercise) -> Bool in
                    exercise.name == name
                }) {
                    try? realm?.write {
                        exercises.remove(at: firstIndex)
                    }
                }
            }
        }
        return sessionInfoText
    }

    func create(session: Session, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        if let list = sessionsList {
            guard !list.sessions.contains(where: {
                $0.name == session.name
            }) else {
                fail?()
                return
            }

            try? realm?.write {
                list.sessions.append(session)
                success?()
            }
        } else {
            let list = SessionsList()
            list.sessions.append(session)
            try? realm?.write {
                realm?.add(list)
                sessionsList = list
                success?()
            }
        }
    }

    func update(_ currentName: String, session: Session, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        guard let newName = session.name,
            let index = index(of: currentName) else {
                fail?()
                return
        }

        if currentName == newName {
            try? realm?.write {
                sessionsList?.sessions[index] = session
                success?()
            }
        } else {
            // Using self because `index` is already used here
            guard self.index(of: newName) == nil else {
                fail?()
                return
            }

            try? realm?.write {
                sessionsList?.sessions.remove(at: index)
                sessionsList?.sessions.append(session)
                success?()
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
}
