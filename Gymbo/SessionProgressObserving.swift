//
//  SessionProgressObserving.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

protocol SessionProgressObserving: class {
    func sessionDidStart(_ notification: Notification)
    func sessionDidEnd(_ notification: Notification)
    func registerForSessionProgressNotifications()
}

extension SessionProgressObserving {
    func sessionDidStart(_ notification: Notification) {}
    func sessionDidEnd(_ notification: Notification) {}

    // Register for Session progress notifications.
    func registerForSessionProgressNotifications() {
        _ = NotificationCenter.default.addObserver(forName: .startSession, object: nil, queue: nil) { [weak self] notification in
            self?.sessionDidStart(notification)
        }

        _ = NotificationCenter.default.addObserver(forName: .endSession, object: nil, queue: nil) { [weak self] notification in
            self?.sessionDidEnd(notification)
        }
    }
}
