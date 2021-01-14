//
//  UIViewController+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension UIViewController {
    var mainTBC: MainTBC? {
        (tabBarController as? MainTBC)
    }

    var minimizedHeight: CGFloat {
        44
    }

    var isOnlyChildVC: Bool {
        guard let navigationController = navigationController else {
            return true
        }
        return navigationController.viewControllers.count == 1
    }

    func presentCustomAlert(alertData: AlertData) {
        let alertVC = AlertVC(alertData: alertData)
        alertVC.modalTransitionStyle = .crossDissolve
        alertVC.modalPresentationStyle = .overFullScreen
        present(alertVC, animated: true)
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

    func dismissAppropriately(animated: Bool = true,
                              completion: (() -> Void)? = nil) {
        guard let navigationController = navigationController,
              !navigationController.viewControllers.isEmpty else {
            dismiss(animated: animated, completion: completion)
            return
        }

        if navigationController.viewControllers.count == 1 {
            dismiss(animated: animated, completion: completion)
        } else {
            navigationController.popViewController(animated: animated)
        }
    }
}
