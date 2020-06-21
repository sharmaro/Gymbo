//
//  UIView+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let dimmedViewColor = UIColor.black.withAlphaComponent(0.8)

    static let animationTime = TimeInterval(0.2)
}

extension UIView {
    func add(subviews: [UIView]) {
        for view in subviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
        }
    }

    func autoPinSafeEdges(to superView: UIView?) {
        guard let superView = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            safeAreaLayoutGuide.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor),
            safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor),
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func autoPinEdges(to superView: UIView?) {
        guard let superView = superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: superView.topAnchor),
            leadingAnchor.constraint(equalTo: superView.leadingAnchor),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        ])
    }

    func addShadow(direction: ShadowDirection) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 1

        switch direction {
        case .up:
            layer.shadowOffset = CGSize(width: 0, height: -4)
        case .left:
            layer.shadowOffset = CGSize(width: -2, height: 0)
        case .right:
            layer.shadowOffset = CGSize(width: 2, height: 0)
        case .down:
            layer.shadowOffset = CGSize(width: 0, height: 4)
        case .upLeft:
            layer.shadowOffset = CGSize(width: -2, height: -4)
        case .upRight:
            layer.shadowOffset = CGSize(width: 2, height: -4)
        case .downLeft:
            layer.shadowOffset = CGSize(width: -2, height: 4)
        case .downRight:
            layer.shadowOffset = CGSize(width: 2, height: 4)
        }
    }

    func showShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
    }

    func hideShadow() {
        layer.shadowColor = UIColor.clear.cgColor
    }

    func removeShadow() {
        layer.shadowColor = UIColor.clear.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
    }

    func addCorner(style: CornerStyle) {
        layer.masksToBounds = true
        layer.cornerRadius = style.radius
    }

    func addDimmedView(animated: Bool = false) {
        let dimmedView = UIView()
        dimmedView.backgroundColor = Constants.dimmedViewColor
        dimmedView.alpha = 0
        dimmedView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(dimmedView)
        dimmedView.autoPinEdges(to: self)

        if animated {
            UIView.animate(withDuration: Constants.animationTime) {
                dimmedView.alpha = 1
            }
        } else {
            dimmedView.alpha = 1
        }
    }

    func removeDimmedView(animated: Bool = false) {
        guard let dimmedView = subviews.last,
            dimmedView.backgroundColor == Constants.dimmedViewColor else {
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

    static var reuseIdentifier: String {
        return String(describing: self)
    }
}