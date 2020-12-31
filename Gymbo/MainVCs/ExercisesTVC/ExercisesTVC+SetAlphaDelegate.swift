//
//  ExercisesTVC+SetAlphaDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension ExercisesTVC: SetAlphaDelegate {
    func setAlpha(alpha: CGFloat) {
        let presentationStyle = customDataSource?.presentationStyle ?? .normal
        if presentationStyle == .modal {
            UIView.animate(withDuration: .defaultAnimationTime,
                           delay: .defaultAnimationTime,
                           options: .curveEaseIn,
                           animations: { [weak self] in
                self?.navigationController?.view.alpha = alpha
            })
        }
    }
}
