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

    private var sessionsList: Results<Session>?

    override init() {
        super.init()

        sessionsList = fetchSessions()

        printConfigFileLocation()
    }

    func printConfigFileLocation() {
        if let configFileURL = realm?.configuration.fileURL {
            print("START SESSION FILE NAME")
            print("config file: \(configFileURL)")
            print("config file_path: \(configFileURL.path)")
            print("config file_relative_path: \(configFileURL.relativePath)")
            print("config file_relative_string: \(configFileURL.relativeString)")
            print("config file_path_extension: \(configFileURL.pathExtension)")
            print("config file_absolute_url: \(configFileURL.absoluteURL)")
            print("config file_absolute_string: \(configFileURL.absoluteString)")
            print("END SESSION FILE NAME")
            print("\n\n\n")
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

    func addSession(session: Session) {
        try? realm?.write {
            realm?.add(session)
        }
    }

    func getSession(forIndex index: Int) -> Session? {
        return sessionsList?[index]
    }

    private func getSessionsCount() -> Int {
        return sessionsList?.count ?? 0
    }

    func getSessionName(forIndex index: Int) -> String {
        return sessionsList?[index].name ?? "No name"
    }

    func getWorkoutsCount(forIndex index: Int) -> Int {
        return sessionsList?[index].workouts.count ?? 0
    }

    func getSessionPreviewInfo(forIndex index: Int) -> [SessionPreviewInfo]? {
        var sessionPreviewInfoList = [SessionPreviewInfo]()
        guard let workouts = sessionsList?[index].workouts,
            workouts.count > 0 else {
                return nil
        }
        for workout in workouts {
            if let workoutName = workout.name, let workoutMuscles = workout.muscleGroups {
                sessionPreviewInfoList.append(SessionPreviewInfo(exerciseName: "\(workout.sets) x \(workoutName)", exerciseMuscles: workoutMuscles))
            }
        }
        return sessionPreviewInfoList
    }

    func workoutsInfoText(forIndex index: Int) -> String {
        var workoutsInfoText = "No workouts selected for this session."
        if let workouts = sessionsList?[index].workouts, workouts.count > 0 {
            workoutsInfoText = ""
            for i in 0..<workouts.count {
                var totalWorkoutString = ""
                let name = Util.formattedString(stringToFormat: workouts[i].name, type: .name)
//                let sets = Util.formattedString(stringToFormat: String(workouts[i].sets), type: .sets)
//                let areRepsUnique = isRepsStringUnique(forWorkout: workouts[i])
//                let reps = Util.formattedString(stringToFormat: workouts[i].workoutDetails[0].reps, type: .reps(areUnique: areRepsUnique))

//                totalWorkoutString = "\(name) - \(sets) x \(reps)"
                totalWorkoutString = "\(name)"
                if i != workouts.count - 1 {
//                    totalWorkoutString += "\n"
                    totalWorkoutString += ", "
                }
                workoutsInfoText.append(totalWorkoutString)
            }
        }
        return workoutsInfoText
    }

    private func isRepsStringUnique(forWorkout workout: Workout) -> Bool {
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
//    func removeSessionAtIndex(_ index: Int) {
//        guard sessionDataModelArray != nil,
//            index > -1, index < sessionDataModelArray!.count else {
//                return
//        }
//        sessionDataModelArray!.remove(at: index)
//    }
}
