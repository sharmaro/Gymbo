//
//  UIExtensions.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let dimmedViewColor = UIColor.black.withAlphaComponent(0.5)

    static let animationTime = TimeInterval(0.2)

    static let locations = "locations"
    static let locationAnimation = "loc"
}

extension UIView {
    func addSubviews(views: [UIView]) {
        for view in views {
            addSubview(view)
        }
    }

    func addShadow() {
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 2.0, height: 4.0)
        layer.shadowRadius = 2.0
        layer.shadowOpacity = 1.0
    }

    func autoPinEdgesTo(superView: UIView?) {
        guard let superView = superview,
            translatesAutoresizingMaskIntoConstraints == false else {
            return
        }

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.topAnchor),
            leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }

    func centerTo(superView: UIView?) {
        guard let superView = superview,
            translatesAutoresizingMaskIntoConstraints == false else {
            return
        }

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superView.centerXAnchor),
            centerYAnchor.constraint(equalTo: superView.centerYAnchor),
        ])
    }

    func leadingAndTrailingTo(superView: UIView?, leading: CGFloat, trailing: CGFloat) {
        guard let superView = superview,
            translatesAutoresizingMaskIntoConstraints == false else {
            return
        }

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.topAnchor),
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: leading),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -trailing),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }

    func addDimmedView(animated: Bool = false) {
        let dimmedView = UIView()
        dimmedView.backgroundColor = Constants.dimmedViewColor
        dimmedView.alpha = 0
        dimmedView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(dimmedView)
        dimmedView.autoPinEdgesTo(superView: self)

        if animated {
            UIView.animate(withDuration: Constants.animationTime) {
                dimmedView.alpha = 1
            }
        } else {
            dimmedView.alpha = 1
        }
    }

    func removeDimmedView(animated: Bool = false) {
        guard let dimmedView = subviews.last, dimmedView.backgroundColor == Constants.dimmedViewColor else {
            return
        }

        if animated {
            UIView.animate(withDuration: Constants.animationTime, animations: {
                dimmedView.alpha = 0
            }) { _ in
                dimmedView.removeFromSuperview()
            }
        } else {
            dimmedView.removeFromSuperview()
        }
    }

    func addMovingLayerAnimation(animatedColor: UIColor = .systemGray, duration: Int, totalTime: Int = 0, timeRemaining: Int = 0) {
        if let sublayer = layer.sublayers?.first as? CAShapeLayer {
            sublayer.removeFromSuperlayer()
        }

        let elapsedTime = totalTime.cgFloat - timeRemaining.cgFloat
        var strokeEnd = elapsedTime / totalTime.cgFloat

        let toPosition = CGPoint(x: bounds.width * 0.5, y: bounds.height * 0.5)

        if totalTime == 0 {
            strokeEnd = 0
        }

        let movingLayer = CAShapeLayer()
        movingLayer.frame = CGRect(origin: CGPoint(x: bounds.width - (bounds.width * strokeEnd), y: 0), size: bounds.size)
        movingLayer.backgroundColor = UIColor.systemGray.cgColor
        layer.insertSublayer(movingLayer, at: 0)

        let movingAnimation = CABasicAnimation(keyPath: "position")
        movingAnimation.fromValue = movingLayer.position
        movingAnimation.toValue = toPosition
        movingAnimation.duration = CFTimeInterval(duration)
        movingAnimation.fillMode = .forwards
        movingAnimation.isRemovedOnCompletion = false

        movingLayer.position = toPosition
        movingLayer.add(movingAnimation, forKey: nil)
    }

    func removeMovingLayerAnimation() {
        if let sublayer = layer.sublayers?.first as? CAShapeLayer {
            sublayer.removeFromSuperlayer()
        }
    }
}
