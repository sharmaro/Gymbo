//
//  StartedSessionTimerDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

protocol StartedSessionTimerDelegate: class {
    func sessionSecondsUpdated()

    func resumeRestTimer()
    func restTimerStarted()
    func restTimeRemainingUpdated()
    func totalRestTimeUpdated()
    func restTimerEnded()
}

extension StartedSessionTimerDelegate {
    func sessionSecondsUpdated() {}

    func resumeRestTimer() {}
    func restTimerStarted() {}
    func restTimeRemainingUpdated() {}
    func totalRestTimeUpdated() {}
    func restTimerEnded() {}
}
