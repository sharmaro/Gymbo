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
    // Personal Info
    dynamic var profileImageName: String?
    dynamic var firstName: String?
    dynamic var lastName: String?
    dynamic var age: String?
    dynamic var weight: String?
    dynamic var height: String?

    // Additional Info
    dynamic var isFirstTimeLoad = true
    var allSessions = List<Session>()
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
    var uniqueDates: [Date] {
        var dates = [Date]()
        for session in allSessions {
            if let completedDate = session.dateCompleted {
                if !dates.contains(where: { (date) -> Bool in
                    completedDate.isSameCalendarDate(as: date)
                }) {
                    dates.append(completedDate)
                }
            }
        }
        return dates
    }

    var allSessionNames: [String] {
        Array(allSessions).map { $0.name ?? "" }
    }

    var canceledSessionNames: [String]? {
        Array(canceledSessions).map { $0.name ?? "" }
    }

    var finishedSessionNames: [String]? {
        Array(finishedSessions).map { $0.name ?? "" }
    }

    func addSession(session: Session, endType: EndType) {
        let sessionLimit = 50
        try? realm?.write {
            session.dateCompleted = Date()

            switch endType {
            case .cancel:
                if canceledSessions.count == sessionLimit {
                    canceledSessions.removeLast()
                }
                canceledSessions.insert(session, at: 0)
            case .finish:
                if finishedSessions.count == sessionLimit {
                    finishedSessions.removeLast()
                }
                finishedSessions.insert(session, at: 0)
            }
            if allSessions.count == sessionLimit {
                allSessions.removeLast()
            }
            allSessions.insert(session, at: 0)
        }
    }

    func sessions(for date: Date) -> [Session] {
        var sessions = [Session]()
        for session in allSessions {
            if session.dateCompleted?
            .isSameCalendarDate(as: date) ?? false {
                sessions.append(session)
            }
        }
        return sessions
    }

    func firstTimeLoadComplete() {
        try? realm?.write {
            isFirstTimeLoad = false
        }
    }
}
