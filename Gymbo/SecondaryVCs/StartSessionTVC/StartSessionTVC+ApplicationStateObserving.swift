//
//  StartSessionTVC+ApplicationStateObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

extension StartSessionTVC: ApplicationStateObserving {
    func didEnterBackground(_ notification: Notification) {
        startSessionTimers?.invalidateAll()
        customDataSource?.saveSession()
        startSessionTimers?.saveTimes()
    }

    func willEnterForeground(_ notification: Notification) {
        customDataSource?.loadData()
        startSessionTimers?.loadData()
    }
}
