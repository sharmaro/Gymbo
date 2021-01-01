//
//  User.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class User: Object {
    dynamic var isFirstTimeLoad = true
    var allPastSessions = List<Session>()
    var canceledSessions = List<Session>()
    var finishedSessions = List<Session>()

    convenience init(canceledSessions: List<Session> = List<Session>(),
                     finishedSessions: List<Session> = List<Session>()) {
        self.init()

        for session in canceledSessions {
            self.canceledSessions.append(session)
        }

        for session in finishedSessions {
            self.finishedSessions.append(session)
        }
    }
}

// MARK: Funcs
extension User {
    var pastSessionNames: [String] {
        Array(allPastSessions).map { $0.name ?? "" }
    }

    var canceledSessionNames: [String]? {
        Array(canceledSessions).map { $0.name ?? "" }
    }

    var finishedSessionNames: [String]? {
        Array(finishedSessions).map { $0.name ?? "" }
    }

    func addSession(session: Session, endType: EndType) {
        try? realm?.write {
            session.dateCompleted = Date()
            switch endType {
            case .cancel:
                canceledSessions.append(session)
            case .finish:
                finishedSessions.append(session)
            }
            allPastSessions.append(session)
        }
    }

    func firstTimeLoadComplete() {
        try? realm?.write {
            isFirstTimeLoad = false
        }
    }
}
