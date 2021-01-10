//
//  ExercisesVC+TransitioningDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension ExercisesVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let presentationStyle = customDataSource?.presentationStyle ?? .normal
        let modalPresentationC = ModalPresentationC(
            presentedViewController: presented,
            presenting: presenting)
        modalPresentationC.showBlurredView = presentationStyle == .normal
        modalPresentationC.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.7)
        return modalPresentationC
    }
}
