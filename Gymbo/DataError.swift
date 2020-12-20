//
//  DataError.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/5/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

enum DataError: Error {
    case createSuccess
    case updateSuccess
    case createFail
    case updateFail

    func exerciseAlertData(exerciseName: String) -> AlertData? {
        var alertData = AlertData(title: "Oops!",
                                  content: "",
                                  usesBothButtons: false,
                                  rightButtonTitle: "Sad!")
        switch self {
        case .createFail:
            alertData.content = "\(exerciseName) already exists."
        case .updateFail:
            alertData.content = "Couldn't edit \(exerciseName)."
        default:
            return nil
        }
        return alertData
    }
}
