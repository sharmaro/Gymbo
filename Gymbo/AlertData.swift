//
//  AlertData.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/5/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

// MARK: - Properties
struct AlertData {
    var title: String?
    var content: String?
    var usesBothButtons: Bool
    var leftButtonTitle: String?
    var rightButtonTitle: String?
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?

    init(title: String? = "Alert",
         content: String?,
         usesBothButtons: Bool = true,
         leftButtonTitle: String? = "Cancel",
         rightButtonTitle: String? = "Confirm",
         leftButtonAction: (() -> Void)? = nil,
         rightButtonAction: (() -> Void)? = nil) {
        self.title = title
        self.content = content
        self.usesBothButtons = usesBothButtons
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }
}
