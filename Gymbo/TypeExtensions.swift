//
//  TypeExtensions.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

enum WorkoutDetailType: String {
    case reps = "reps"
    case weight = "weight"
    case time = "sec"
    case additionalInfo = "additional info"
}

import Foundation

extension String {
    func formattedValue(type: WorkoutDetailType) -> String{
        if self.count == 0 {
            return ""
        }
        var suffix = ""
        switch type {
        case .reps:
            if let reps = Int(self), reps != 0 {
                suffix = reps > 1 ? "reps" : "rep"
            } else {
                suffix = "reps"
            }
        case .weight:
            if let weight = Double(self), weight != 0 {
                suffix = weight > 1 ? "lbs" : "lb"
            } else {
                suffix = "lbs"
            }
        case .time:
            if let time = Int(self), time != 0 {
                suffix = time > 1 ? "secs" : "sec"
            } else {
                suffix = "secs"
            }
        case .additionalInfo:
            suffix = ""
        }
        return "\(self) \(suffix)"
    }
}
