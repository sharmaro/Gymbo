//
//  SessionDataModelManager.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/12/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation
import RealmSwift

class SessionDataModelManager: NSObject {
    static var shared = SessionDataModelManager()
    
    private var realm = try? Realm()
    
    var sessionsCount: Int? {
        return getSessionsCount()
    }
    
    private var sessionDataModelArray: Results<Session>?

    override init() {
        super.init()

        sessionDataModelArray = fetchSessions()

        printConfigFileLocation()
    }
    
    func printConfigFileLocation() {
        if let configFileURL = realm?.configuration.fileURL {
            print("config file: \(configFileURL)")
            print("config file_path: \(configFileURL.path)")
            print("config file_relative_path: \(configFileURL.relativePath)")
            print("config file_relative_string: \(configFileURL.relativeString)")
            print("config file_path_extension: \(configFileURL.pathExtension)")
            print("config file_absolute_url: \(configFileURL.absoluteURL)")
            print("config file_absolute_string: \(configFileURL.absoluteString)")
        }
    }

    private func fetchSessions() -> Results<Session>? {
        return realm?.objects(Session.self)
    }

    func removeAllRealmData() {
        try? realm?.write {
            realm?.deleteAll()
        }
    }
    
    private func getSessionsCount() -> Int {
        return sessionDataModelArray?.count ?? 0
    }
    
    func saveSession(session: Session) {
        try? realm?.write {
            realm?.add(session)
        }
    }
    
    func getSessionNameForIndex(index: Int) -> String {
        return sessionDataModelArray?[index].name ?? "No name"
    }
    
    func workoutsCountForSession(index: Int) -> Int {
        return sessionDataModelArray?[index].workouts.count ?? 0
    }

    func workoutsInfoTextForSession(index: Int) -> String {
        var workoutsInfoText = "No workouts selected for this session."
        if let workouts = sessionDataModelArray?[index].workouts, workouts.count > 0 {
            workoutsInfoText = ""
            for i in 0..<workouts.count {
                var totalWorkoutString = ""
                let name = Util.formattedString(stringToFormat: workouts[i].name, type: .name)
                let sets = Util.formattedString(stringToFormat: String(workouts[i].sets), type: .sets)
                let areRepsUnique = isRepsStringUnique(workout: workouts[i])
                let reps = Util.formattedString(stringToFormat: workouts[i].workoutDetails[0].reps, type: .reps(areUnique: areRepsUnique))

                totalWorkoutString = "\(name) - \(sets) x \(reps)"
                if i != workouts.count - 1 {
                    totalWorkoutString += "\n"
                }
                workoutsInfoText.append(totalWorkoutString)
            }
        }
        return workoutsInfoText
    }

    private func isRepsStringUnique(workout: Workout) -> Bool {
        var areUnique = false
        let workoutDetails = workout.workoutDetails
        if workoutDetails.count == 1 {
            return areUnique
        }

        let reps = workoutDetails[0].reps
        for workoutDetail in workoutDetails {
            if workoutDetail.reps != reps {
                areUnique.toggle()
                return areUnique
            }
        }
        return areUnique
    }

//    func getWorkoutsForIndex(_ index: Int) -> [Workout]? {
//        guard let sessionArray = sessionDataModelArray else {
//            return nil
//        }
//        return sessionArray[index].workouts
//    }
//
//    func getWorkoutCountForIndex(_ index: Int) -> Int {
//        return sessionDataModelArray?[index].workouts?.count ?? 0
//    }
//
//    func addSession(_ session: Session) {
//        sessionDataModelArray?.append(session)
//    }
//
//    func replaceSessionAtIndex(_ index: Int, _ session: Session) {
//        guard sessionDataModelArray != nil,
//        index > -1, index < sessionDataModelArray!.count else {
//            return
//        }
//        sessionDataModelArray![index] = session
//    }
//
//    func removeSessionAtIndex(_ index: Int) {
//        guard sessionDataModelArray != nil,
//            index > -1, index < sessionDataModelArray!.count else {
//                return
//        }
//        sessionDataModelArray!.remove(at: index)
//    }
}
