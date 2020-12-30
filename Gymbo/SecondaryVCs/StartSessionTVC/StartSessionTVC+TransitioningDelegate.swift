//
//  StartSessionTVC+TransitioningDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartSessionTVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationC = ModalPresentationC(
            presentedViewController: presented,
            presenting: presenting)

        switch customDataSource?.modallyPresenting ?? .none {
        case .restVC:
            modalPresentationC.customBounds = CustomBounds(horizontalPadding: 20,
                                                           percentHeight: 0.7)
        case .exercisesTVC:
            modalPresentationC.customBounds = CustomBounds(horizontalPadding: 20,
                                                           percentHeight: 0.8)
        case .none:
            break
        }
        return modalPresentationC
    }
}
