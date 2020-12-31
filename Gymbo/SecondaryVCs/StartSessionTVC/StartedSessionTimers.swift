//
//  StartedSessionTimers.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class StartedSessionTimers: NSObject {
    var sessionSeconds = 0 {
        didSet {
            startedSessionTimerDelegate?.sessionSecondsUpdated()
        }
    }

    var totalRestTime = 0 {
        didSet {
            startedSessionTimerDelegate?.totalRestTimeUpdated()
        }
    }

    var restTimeRemaining = 0 {
        didSet {
            startedSessionTimerDelegate?.restTimeRemainingUpdated()
        }
    }

    var sessionTimer: Timer?
    var restTimer: Timer?

    weak var startedSessionTimerDelegate: StartedSessionTimerDelegate?

    private let defaults = UserDefaults.standard
}

// MARK: - Structs/Enums
private extension StartedSessionTimers {
    struct Constants {
        static let timeInterval = TimeInterval(1)

        static let SESSION_SECONDS_KEY = "sessionSeconds"
        static let REST_TOTAL_TIME_KEY = "restTotalTime"
        static let REST_REMAINING_TIME_KEY = "restRemainingTime"
    }
}

// MARK: - Funcs
extension StartedSessionTimers {
    @objc private func updateSessionTime() {
        sessionSeconds += 1
    }

    @objc private func updateRestTime() {
        restTimeRemaining -= 1
        if restTimeRemaining <= 0 {
            Haptic.sendNotificationFeedback(.success)
            restTimer?.invalidate()
            startedSessionTimerDelegate?.restTimerEnded()
        }
    }

    func loadData() {
        let realm = try? Realm()
        if realm?.objects(StartedSession.self).first != nil,
           let date = defaults.object(forKey: UserDefaultKeys.STARTSESSION_DATE) as? Date,
           let timeDictionary = defaults.object(
                forKey: UserDefaultKeys.STARTSESSION_TIME_DICTIONARY) as? [String: Int],
           let previousSessionSeconds = timeDictionary[Constants.SESSION_SECONDS_KEY] {
            let secondsElapsed = Int(Date().timeIntervalSince(date))
            sessionSeconds = previousSessionSeconds + secondsElapsed

            let restTotalTime = timeDictionary[Constants.REST_TOTAL_TIME_KEY] ?? 0
            let restRemainingTime = timeDictionary[Constants.REST_REMAINING_TIME_KEY] ?? 0
            let newTimeRemaining = restRemainingTime - secondsElapsed

            if newTimeRemaining > 0 {
                totalRestTime = restTotalTime
                restTimeRemaining = newTimeRemaining

                startRestTimer()
                startedSessionTimerDelegate?.resumeRestTimer()
            }
        }
        startSessionTimer()
    }

    func saveTimes() {
        let timeDictionary: [String: Int] = [
            Constants.SESSION_SECONDS_KEY: sessionSeconds,
            Constants.REST_TOTAL_TIME_KEY: totalRestTime,
            Constants.REST_REMAINING_TIME_KEY: restTimeRemaining
        ]

        defaults.set(Date(), forKey: UserDefaultKeys.STARTSESSION_DATE)
        defaults.set(timeDictionary, forKey: UserDefaultKeys.STARTSESSION_TIME_DICTIONARY)
    }

    func startSessionTimer() {
        sessionTimer = Timer.scheduledTimer(timeInterval: Constants.timeInterval,
                                            target: self,
                                            selector: #selector(updateSessionTime),
                                            userInfo: nil,
                                            repeats: true)
        if let timer = sessionTimer {
            // Allows it to update the navigation bar.
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func startedRestTimer(totalTime: Int) {
        totalRestTime = totalTime
        restTimeRemaining = totalTime
        startedSessionTimerDelegate?.restTimerStarted()
        startRestTimer()
    }

    func startRestTimer() {
        restTimer?.invalidate()
        restTimer = Timer.scheduledTimer(timeInterval: Constants.timeInterval,
                                         target: self,
                                         selector: #selector(updateRestTime),
                                         userInfo: nil,
                                         repeats: true)
        if let timer = restTimer {
            // Allows it to update in the navigation bar.
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stopRestTimer() {
        restTimer?.invalidate()
        startedSessionTimerDelegate?.restTimerEnded()
    }

    func invalidateAll() {
        sessionTimer?.invalidate()
        restTimer?.invalidate()
    }
}
