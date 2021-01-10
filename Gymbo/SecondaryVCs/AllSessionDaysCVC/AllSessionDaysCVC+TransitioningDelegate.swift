//
//  AllSessionDaysCVC+TransitioningDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/10/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

extension AllSessionDaysCVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationC = ModalPresentationC(
            presentedViewController: presented,
            presenting: presenting)
        modalPresentationC.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.5)
        return modalPresentationC
    }
}
