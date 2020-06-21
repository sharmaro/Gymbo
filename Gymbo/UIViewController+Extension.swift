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
        let viewToUse = navigationController?.view == nil ? view : navigationController?.view

        let backgroundView = UIView(frame: viewToUse?.bounds ?? .zero)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.center = backgroundView.center
        activityIndicatorView.startAnimating()

        backgroundView.addSubview(activityIndicatorView)
        viewToUse?.addSubview(backgroundView)
    }

    func hideActivityIndicator() {
        let viewToUse = navigationController?.view == nil ? view : navigationController?.view

        guard let backgroundView = viewToUse?.subviews.last,
            backgroundView.subviews.first is UIActivityIndicatorView else {
            return
        }
        backgroundView.removeFromSuperview()
    }
}
