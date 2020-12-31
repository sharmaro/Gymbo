//
//  StartedSessionTVC+ApplicationStateObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

extension StartedSessionTVC: ApplicationStateObserving {
    func didEnterBackground(_ notification: Notification) {
        startedSessionTimers?.invalidateAll()
        customDataSource?.saveSession()
        startedSessionTimers?.saveTimes()
    }

    func willEnterForeground(_ notification: Notification) {
        customDataSource?.loadData()
        startedSessionTimers?.loadData()
    }
}
