//
//  UIViewController+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension UIViewController {
    var mainTabBarController: MainTabBarController? {
        return (tabBarController as? MainTabBarController)
    }

    var minimizedHeight: CGFloat {
        return 44
    }

    func presentCustomAlert(title: String = "Alert", content: String, usesBothButtons: Bool = true, leftButtonTitle: String = "Cancel", rightButtonTitle: String = "Confirm", leftButtonAction: (() -> Void)? = nil, rightButtonAction: (() -> Void)? = nil) {
        let alertViewController = AlertViewController()
        alertViewController.setupAlert(title: title, content: content, usesBothButtons: usesBothButtons, leftButtonTitle: leftButtonTitle, rightButtonTitle: rightButtonTitle, leftButtonAction: leftButtonAction, rightButtonAction: rightButtonAction)
        alertViewController.modalTransitionStyle = .crossDissolve
        alertViewController.modalPresentationStyle = .overFullScreen
        present(alertViewController, animated: true)
    }

    func showActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            let viewToUse = self?.mainTabBarController?.view == nil ? self?.view : self?.mainTabBarController?.view

            let blurEffect = UIBlurEffect(style: .dark)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.frame = viewToUse?.bounds ?? .zero

            let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicatorView.center = blurredEffectView.center
            activityIndicatorView.startAnimating()

            blurredEffectView.contentView.addSubview(activityIndicatorView)
            viewToUse?.addSubview(blurredEffectView)
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            let viewToUse = self?.mainTabBarController?.view == nil ? self?.view : self?.mainTabBarController?.view

            guard let visualEffectView = viewToUse?.subviews.last as? UIVisualEffectView else {
                return
            }
            visualEffectView.removeFromSuperview()
        }
    }
}
