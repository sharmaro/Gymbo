//
//  SessionDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/8/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation

struct WorkoutDetails: Decodable {
    var reps: String?
    var weight: String?
    var time: String?
    var additionalInfo: String?
    
    init() {
        reps = nil
        weight = nil
        time = nil
        additionalInfo = nil
    }
    
    init(reps: String?, weight: String?, time: String?, additionalInfo: String?) {
        self.reps = reps
        self.weight = weight
        self.time = time
        self.additionalInfo = additionalInfo
    }
    
    func printInfo() {
        print("reps: \(String(describing: reps))")
        print("weight: \(String(describing: weight))")
        print("time: \(String(describing: time))")
        print("additional info: \(String(describing: additionalInfo))")
    }
}

struct Workout: Decodable {
    var name: String?
    var sets: Int?
    var workoutDetails: [WorkoutDetails]?
    
    init() {
        name = nil
        sets = nil
        workoutDetails = nil
    }
    
    init(name: String? = nil, sets: Int? = nil, workoutDetails: [WorkoutDetails]?) {
        self.name = name
        self.sets = sets
        self.workoutDetails = workoutDetails
    }
    
    func printInfo() {
        print("name: \(String(describing: name))")
        print("sets: \(String(describing: sets))")
        if let sets = sets {
            for i in 0..<sets {
                if let details = workoutDetails {
                    print("workoutDetails: \(details[i].printInfo())")
                }
            }
        }
    }
    
    func getWorkoutText() -> String {
        return "\(name ?? "name") | \(sets ?? 0))"
    }
}

struct SessionDataModel: Decodable {
    var sessionName: String?
    var workouts: [Workout]?
    
    init() {
        sessionName = ""
        workouts = nil
    }
    
    init(sessionName: String?, workouts: [Workout]?) {
        self.sessionName = sessionName
        self.workouts = workouts
    }
    
    func printInfo() {
        print("---------------")
        print("session name: \(String(describing: sessionName))")
        workouts?.forEach( {$0.printInfo()} )
        print("---------------")
        print()
    }
    
    func getWorkoutText() -> String {
        var completeString = ""
        if let workouts = self.workouts {
            for workout in workouts {
                completeString.append("\(workout.getWorkoutText())\n")
            }
        }
        
        return completeString
    }
}
