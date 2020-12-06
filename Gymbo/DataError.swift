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
    case createFail
    case updateSuccess
    case updateFail

    func alertData(data: String) -> AlertData? {
        var alertData = AlertData(title: "Oops!",
                                  content: "",
                                  usesBothButtons: false,
                                  rightButtonTitle: "Sad!")
        switch self {
        case .createFail:
            alertData.content = "\(data) already exists."
        case .updateFail:
            alertData.content = "Couldn't edit exercise \(data)."
        default:
            return nil
        }
        return alertData
    }
}
