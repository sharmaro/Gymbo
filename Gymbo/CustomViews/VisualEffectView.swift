//
//  VisualEffectView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/9/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class VisualEffectView: UIVisualEffectView {
    init(frame: CGRect = .zero, style: UIBlurEffect.Style = .dark) {
        let blurEffect = UIBlurEffect(style: style)
        super.init(effect: blurEffect)

        self.frame = frame
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}
