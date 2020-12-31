//
//  CreateEditSessionTVC+TransitioningDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension CreateEditSessionTVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationC = ModalPresentationC(
            presentedViewController: presented,
            presenting: presenting)
        modalPresentationC.customBounds = CustomBounds(horizontalPadding: 20,
                                                       percentHeight: 0.8)
        return modalPresentationC
    }
}
