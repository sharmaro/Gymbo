//
//  SessionDataModelManager.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/12/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation

class SessionDataModelManager: NSObject {
    
    static var shared = SessionDataModelManager()
    
    var areRepsUnique: Bool {
        // TODO:
        // Find out if all the reps in a workout are the same or unique
        return false
    }
    
    private var sessionDataModelArray: [SessionDataModel]? {
        get {
            // Initialize session data model here from stored data
            return nil
        }
        set {}
    }
    
    override init() {}
    
    func getSessionCount() -> Int {
        return sessionDataModelArray?.count ?? 0
    }
    
    func getSessionNameForIndex(_ index: Int) -> String? {
        guard let sessionArray = sessionDataModelArray else {
            return nil
        }
        return sessionArray[index].sessionName
    }
    
    func getWorkoutsForIndex(_ index: Int) -> [Workout]? {
        guard let sessionArray = sessionDataModelArray else {
            return nil
        }
        return sessionArray[index].workouts
    }
    
    func getWorkoutCountForIndex(_ index: Int) -> Int {
        return sessionDataModelArray?[index].workouts?.count ?? 0
    }
    
    func addSession(_ session: SessionDataModel) {
        sessionDataModelArray?.append(session)
    }
    
    func replaceSessionAtIndex(_ index: Int, _ session: SessionDataModel) {
        guard sessionDataModelArray != nil,
        index > -1, index < sessionDataModelArray!.count else {
            return
        }
        sessionDataModelArray![index] = session
    }
    
    func removeSessionAtIndex(_ index: Int) {
        guard sessionDataModelArray != nil,
            index > -1, index < sessionDataModelArray!.count else {
                return
        }
        sessionDataModelArray!.remove(at: index)
    }
}
