//
//  UIView+Extension.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension UIView {
    static var reuseIdentifier: String {
        String(describing: self)
    }

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
            safeAreaLayoutGuide.topAnchor.constraint(
                equalTo: superView.safeAreaLayoutGuide.topAnchor),
            safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: superView.safeAreaLayoutGuide.leadingAnchor),
            safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: superView.safeAreaLayoutGuide.trailingAnchor),
            safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: superView.safeAreaLayoutGuide.bottomAnchor)
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

    func addShadow(direction: Direction) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.dynamicDarkGray.cgColor
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.6

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
        layer.shadowColor = UIColor.dynamicDarkGray.cgColor
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
        dimmedView.backgroundColor = .dimmedBackgroundBlack
        dimmedView.alpha = 0
        dimmedView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(dimmedView)
        dimmedView.autoPinEdges(to: self)

        if animated {
            UIView.animate(withDuration: .defaultAnimationTime) {
                dimmedView.alpha = 1
            }
        } else {
            dimmedView.alpha = 1
        }
    }

    func removeDimmedView(animated: Bool = false) {
        guard let dimmedView = subviews.last,
            dimmedView.backgroundColor == .dimmedBackgroundBlack else {
            return
        }

        if animated {
            UIView.animate(withDuration: .defaultAnimationTime,
                           animations: {
                dimmedView.alpha = 0
            }) { _ in
                dimmedView.removeFromSuperview()
            }
        } else {
            dimmedView.removeFromSuperview()
        }
    }

    func addMovingLayerAnimation(animatedColor: UIColor = .systemGray, duration: Int,
                                 totalTime: Int = 0, timeRemaining: Int = 0) {
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
        movingLayer.frame = CGRect(origin: CGPoint(x: bounds.width - (bounds.width * strokeEnd), y: 0),
                                   size: bounds.size)
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

    // Border width needs to be set before calling this
    func animateBorderColor(from: UIColor, to: UIColor) {
        let animationKey = "borderColor"
        let colorAnimation = CABasicAnimation(keyPath: animationKey)
        colorAnimation.fromValue = from.cgColor
        colorAnimation.toValue = to.cgColor
        colorAnimation.duration = .defaultAnimationTime
        layer.borderColor = to.cgColor
        layer.add(colorAnimation, forKey: animationKey)

    }

    // Border width needs to be set before calling this
    func animateBorderWidth(from: CGFloat, to: CGFloat) {
        let animationKey = "borderWidth"
        let widthAnimation = CABasicAnimation(keyPath: animationKey)
        widthAnimation.fromValue = from
        widthAnimation.toValue = to
        widthAnimation.duration = .defaultAnimationTime
        layer.borderWidth = to
        layer.add(widthAnimation, forKey: animationKey)
    }

    // Border width needs to be set before calling this
    func animateBorderColorAndWidth(fromColor: UIColor, toColor: UIColor,
                                    fromWidth: CGFloat, toWidth: CGFloat) {
        let colorAnimation = CABasicAnimation(keyPath: "borderColor")
        colorAnimation.fromValue = fromColor.cgColor
        colorAnimation.toValue = toColor.cgColor
        layer.borderColor = toColor.cgColor

        let widthAnimation = CABasicAnimation(keyPath: "borderWidth")
        widthAnimation.fromValue = fromWidth
        widthAnimation.toValue = toWidth
        layer.borderWidth = toWidth

        let bothAnimations = CAAnimationGroup()
        bothAnimations.duration = .defaultAnimationTime
        bothAnimations.animations = [colorAnimation, widthAnimation]
        bothAnimations.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        layer.add(bothAnimations, forKey: "color and width")
    }

    func addBorder(_ width: CGFloat = 1, color: UIColor = .black) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }

    func addGradient(axis: Axis = .horizontal, colors: [UIColor]) {
        guard !(layer.sublayers?.first is CAGradientLayer) else {
            return
        }

        layer.masksToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        switch axis {
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        }
        gradientLayer.addCorner(style: .small)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    func removeGradient() {
        guard let gradientLayer = layer.sublayers?.first as? CAGradientLayer else {
            return
        }
        gradientLayer.removeFromSuperlayer()
    }
}
