//
//  ModalPresentationController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct CustomBounds {
    var horizontalPadding: CGFloat
    var percentHeight: CGFloat
}

// MARK: - Properties
final class ModalPresentationController: UIPresentationController {
    private lazy var dimmingView: UIView = {
        guard let containerView = containerView else {
            return UIView()
        }

        let dimmingView = UIView(frame: containerView.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(Constants.dimmedAlpha)
        if customBounds == nil {
            dimmingView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(dismiss))
            )
        }

        return dimmingView
    }()

    private lazy var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(didPan))
    }()

    var customBounds: CustomBounds?
    var showDimmingView = true
    private var hasRegisteredForKeyboardNotifications = false

    // MARK: - UIPresentationController Var/Funcs
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }

        if let bounds = customBounds {
            if !hasRegisteredForKeyboardNotifications {
                hasRegisteredForKeyboardNotifications = true
                registerForKeyboardNotifications()
            }
            let width = containerView.bounds.width - (2 * bounds.horizontalPadding)
            let height = containerView.bounds.height * bounds.percentHeight
            let size = CGSize(width: width, height: height)

            let x = bounds.horizontalPadding
            let y = (containerView.bounds.height - height) / 2
            let origin = CGPoint(x: x, y: y)

            return CGRect(origin: origin, size: size)
        }

        let defaultHeight = containerView.bounds.height - Constants.defaultYOffset
        return CGRect(origin: CGPoint(x: 0, y: Constants.defaultYOffset), size: CGSize(width: containerView.bounds.width, height: defaultHeight))
    }

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        panGesture.delegate = self
        presentedViewController.view.addGestureRecognizer(panGesture)
    }

    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        presentedView?.roundCorner(radius: Constants.cornerRadius)
        let maskedCorners: CACornerMask = customBounds == nil ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        presentedView?.layer.maskedCorners = maskedCorners
    }

    override func presentationTransitionWillBegin() {
        guard let container = containerView,
            let coordinator = presentingViewController.transitionCoordinator,
            showDimmingView else {
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
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator,
        showDimmingView else {
            return
        }

        coordinator.animate(alongsideTransition: { [weak self] _ -> Void in
            guard let self = self else {
                return
            }
            self.dimmingView.alpha = 0
        })
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed, showDimmingView {
            dimmingView.removeFromSuperview()
        }
    }
}

// MARK: - Structs/Enums
extension ModalPresentationController {
    private struct Constants {
        static let animationDuration = TimeInterval(0.4)
        static let delayDuration = TimeInterval(0)

        static let defaultYOffset = CGFloat(60)
        static let dimmedAlpha = CGFloat(0.8)
        static let dampingDuration = CGFloat(1)
        static let velocity = CGFloat(0.7)
        static let cornerRadius = CGFloat(10)
        static let centerWidthPadding = CGFloat(80)
        static let centerHeightPadding = CGFloat(0.7)
        static let keyboardSpacing = CGFloat(10)
    }
}

// MARK: - Funcs
extension ModalPresentationController {
    @objc private func didPan(gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view,
            let presented = presentedView, let container = containerView else {
                return
        }

        let location = gestureRecognizer.translation(in: view)

        switch gestureRecognizer.state {
        case .changed:
            let offset = location.y + Constants.defaultYOffset

            if offset > frameOfPresentedViewInContainerView.origin.y {
                presented.frame.origin.y = offset
            }
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: view)
            let maxPresentedY = (container.frame.height - Constants.defaultYOffset) / 2

            if velocity.y > 600 {
                presentedViewController.dismiss(animated: true)
            } else {
                if presented.frame.origin.y < maxPresentedY {
                    resizeToFullView()
                } else {
                    presentedViewController.dismiss(animated: true)
                }
            }
        default:
            break
        }
    }

    private func resizeToFullView() {
        guard let presentedView = presentedView else {
            return
        }

        UIView.animate(withDuration: Constants.animationDuration, delay: Constants.delayDuration, usingSpringWithDamping: Constants.dampingDuration, initialSpringVelocity: Constants.velocity, options: .curveEaseInOut, animations: { [weak self] in
            guard let self = self else {
                return
            }
            presentedView.frame.origin = self.frameOfPresentedViewInContainerView.origin
        })
    }

    @objc private func dismiss() {
        presentedViewController.dismiss(animated: true)
    }
}

// MARK: - KeyboardObserving
extension ModalPresentationController: KeyboardObserving {
    func keyboardWillShow(_ notification: Notification) {
        presentedViewController.view.removeGestureRecognizer(panGesture)

        guard let keyboardHeight = notification.keyboardSize?.height,
            let presentedView = presentedView,
            let containerView = containerView else {
            return
        }

        let minYOfKeyboard = containerView.frame.height - keyboardHeight
        let heightToRemove = abs(presentedView.frame.maxY - minYOfKeyboard)
        let minYLimitOfPresentedView = presentedView.frame.origin.y / 3

        /**
         - minYLimitOfPresentedView is 1/3 of it's original origin.y
         - Need to call (2 * newYOrigin) because that's how much space should not be removed from the new height
        */
        guard minYOfKeyboard != presentedView.frame.maxY + Constants.keyboardSpacing else {
            return
        }

        let newFrame: CGRect
        // Checking to see if the new origin of presented view is >= minYLimitOfPresentedView
        if containerView.frame.height - keyboardHeight - Constants.keyboardSpacing - presentedView.frame.height >= minYLimitOfPresentedView {
            newFrame = CGRect(origin: CGPoint(x: presentedView.frame.origin.x, y: containerView.frame.height - keyboardHeight - presentedView.frame.height - Constants.keyboardSpacing), size: presentedView.frame.size)
        } else {
            newFrame = CGRect(origin: CGPoint(x: presentedView.frame.origin.x, y: minYLimitOfPresentedView), size: CGSize(width: presentedView.frame.width, height: presentedView.frame.height + (2 * minYLimitOfPresentedView) - heightToRemove - Constants.keyboardSpacing))
        }
        presentedView.frame = newFrame
        presentedView.layoutIfNeeded()
    }

    func keyboardWillHide(_ notification: Notification) {
        if let presentedView = presentedView {
            presentedView.frame = frameOfPresentedViewInContainerView
            presentedView.layoutIfNeeded()
        }
        presentedViewController.view.addGestureRecognizer(panGesture)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ModalPresentationController: UIGestureRecognizerDelegate {
    // Preventing panGesture eating up table view gestures
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer != panGesture
    }
}
