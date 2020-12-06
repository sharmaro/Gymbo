//
//  SessionsList.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// Need to create a List object that stores a List of objects if order is important
// Realm will not store objects in order
@objcMembers class SessionsList: Object {
    let sessions = List<Session>()
}
