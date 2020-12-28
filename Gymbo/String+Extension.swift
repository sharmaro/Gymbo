//
//  String+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

extension String {
    var firstCharacter: String? {
        guard let firstCharacter = first else {
            return nil
        }
        return String(firstCharacter)
    }

    var secondsFromTime: Int? {
        let times = Array(self)
        guard times.count == 5 else {
            return nil
        }

        let minutes = Int("\(times[0])\(times[1])") ?? 0
        let seconds = Int("\(times[3])\(times[4])") ?? 0
        return (minutes * 60) + seconds
    }
}
