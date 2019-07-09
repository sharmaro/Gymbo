//
//  SessionDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/8/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import Foundation

struct Workout: Decodable {
    var name: String?
    var sets: Int?
    var reps: Int?
    var weight: Double?
    var time: Int?
    var additionalInfo: String?
    
    init() {
        name = nil
        sets = nil
        reps = nil
        weight = nil
        time = nil
        additionalInfo = nil
    }
    
    init(name: String? = nil, sets: Int? = nil, reps: Int? = nil, weight: Double, time: Int? = nil, additionalInfo: String? = nil) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.time = time
        self.additionalInfo = additionalInfo
    }
    
    func printInfo() {
        print("name: \(String(describing: name))")
        print("sets: \(String(describing: sets))")
        print("reps: \(String(describing: reps))")
        print("weight: \(String(describing: weight))")
        print("time: \(String(describing: time))")
        print("additionalInfo: \(String(describing: additionalInfo))")
    }
}

struct SessionDataModel: Decodable {
    var workouts: [Workout]?
    
    init() {
        workouts = nil
    }
    
    init(workouts: [Workout]) {
        self.workouts = workouts
    }
    
    func printInfo() {
        print("---------------")
        workouts?.forEach( {$0.printInfo()} )
        print("---------------")
        print()
    }
}
