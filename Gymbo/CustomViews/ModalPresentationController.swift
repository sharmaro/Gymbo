//
//  ModalPresentationController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

final class ModalPresentationController: UIPresentationController {
    // MARK: - Properties
    private lazy var dimmingView: UIView = {
        guard let containerView = containerView else {
            return UIView()
        }

        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(Constants.dimmedAlpha)
        if !center {
            dimmingView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(dismiss))
            )
        }

        return dimmingView
    }()

    private var defaultYOffset = CGFloat(60)
    var center = false

    // MARK: - UIPresentationController Var/Funcs
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }

        if center {
            let width = containerView.bounds.width - Constants.centerWidthPadding
            let height = containerView.bounds.height * Constants.centerHeightPadding
            let size = CGSize(width: width, height: height)

            let x = Constants.centerWidthPadding / 2
            let y = (containerView.bounds.height - height) / 2
            let origin = CGPoint(x: x, y: y)

            return CGRect(origin: origin, size: size)
        }

        let defaultHeight = containerView.bounds.height - defaultYOffset
        return CGRect(origin: CGPoint(x: 0, y: defaultYOffset), size: CGSize(width: containerView.bounds.width, height: defaultHeight))
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        presentedViewController.view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(didPan))
        )
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        presentedView?.layer.masksToBounds = true
        presentedView?.layer.cornerRadius = Constants.cornerRadius
        let maskedCorners: CACornerMask = center ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView?.layer.maskedCorners = maskedCorners
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator else {
                return
        }

        dimmingView.alpha = 0
        dimmingView.addSubview(presentedViewController.view)
        container.addSubview(dimmingView)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else {
                return
            }
            self.dimmingView.alpha = 1

            }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else {
            return
        }

        coordinator.animate(alongsideTransition: { [weak self] _ -> Void in
            guard let self = self else {
                return
            }
            self.dimmingView.alpha = 0

            }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}

// MARK: - Structs/Enums
private extension ModalPresentationController {
    struct Constants {
        static let animationDuration = TimeInterval(0.4)
        static let delayDuration = TimeInterval(0)

        static let dimmedAlpha = CGFloat(0.8)
        static let dampingDuration = CGFloat(1)
        static let velocity = CGFloat(0.7)
        static let cornerRadius = CGFloat(20)
        static let centerWidthPadding = CGFloat(80)
        static let centerHeightPadding = CGFloat(0.7)
    }
}

// MARK: - Funcs
extension ModalPresentationController {
    @objc func didPan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view,
            let presented = presentedView, let container = containerView else {
                return
        }

        let location = gestureRecognizer.translation(in: view)

        switch gestureRecognizer.state {
        case .changed:
            let offset = location.y + defaultYOffset

            if offset > frameOfPresentedViewInContainerView.origin.y {
                presented.frame.origin.y = location.y + defaultYOffset
            }
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: view)
            let maxPresentedY = (container.frame.height - defaultYOffset) / 2

            if velocity.y > 600 {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                switch presented.frame.origin.y {
                case 0 ... maxPresentedY:
                    resizeToFull()
                default:
                    presentedViewController.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }

    private func resizeToFull() {
        guard let presentedView = presentedView else {
            return
        }

        UIView.animate(withDuration: Constants.animationDuration, delay: Constants.delayDuration, usingSpringWithDamping: Constants.dampingDuration, initialSpringVelocity: Constants.velocity, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else {
                return
            }
            presentedView.frame.origin = self.frameOfPresentedViewInContainerView.origin
        }, completion: nil)
    }

    @objc private func dismiss() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
