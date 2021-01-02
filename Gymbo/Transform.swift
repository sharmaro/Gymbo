//
//  Transform.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

enum Transform {
    case shrink
    case inflate

    static func caseFromBool(bool: Bool) -> Transform {
        bool ? .shrink : .inflate
    }

    func transform(view: UIView) {
        UIView.animate(withDuration: .defaultAnimationTime,
                       delay: 0,
                       options: [.allowUserInteraction],
                       animations: {
            switch self {
            case .shrink:
                view.transform = CGAffineTransform(scaleX: Constants.transformScale,
                                                   y: Constants.transformScale)
            case .inflate:
                view.transform = CGAffineTransform.identity
            }
        })
    }
}

// MARK: - Structs/Enums
private extension Transform {
    struct Constants {
        static let transformScale = CGFloat(0.95)
    }
}
