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
        (tabBarController as? MainTabBarController)
    }

    var minimizedHeight: CGFloat {
        44
    }

    func presentCustomAlert(alertData: AlertData) {
        let alertViewController = AlertViewController(alertData: alertData)
        alertViewController.modalTransitionStyle = .crossDissolve
        alertViewController.modalPresentationStyle = .overFullScreen
        present(alertViewController, animated: true)
    }

    func showActivityIndicator(withText text: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            let viewToUse =
                self?.navigationController?.view == nil ?
                self?.view :
                self?.navigationController?.view

            let activityIndicatorView = ActivityIndicatorView(withText: text)
            viewToUse?.add(subviews: [activityIndicatorView])
            activityIndicatorView.autoPinEdges(to: viewToUse)
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            let viewToUse =
                self?.navigationController?.view == nil ?
                self?.view :
                self?.navigationController?.view

            guard let activityIndicatorView = viewToUse?.subviews.last as? ActivityIndicatorView else {
                return
            }

            UIView.animate(withDuration: .defaultAnimationTime,
                           animations: {
                activityIndicatorView.alpha = 0
            }) { _ in
                activityIndicatorView.removeFromSuperview()
            }
        }
    }
}
