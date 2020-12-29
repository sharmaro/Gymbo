//
//  Haptic.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/21/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
struct Haptic {}

// MARK: - Funcs
extension Haptic {
    static func sendNotificationFeedback(_ style: UINotificationFeedbackGenerator.FeedbackType) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(style)
    }

    static func sendImpactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
    }

    static func sendSelectionFeedback() {
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
    }
}
