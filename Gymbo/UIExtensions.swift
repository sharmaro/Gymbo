//
//  UIExtensions.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

enum ShadowDirection {
    case up
    case left
    case right
    case down
    case upLeft
    case upRight
    case downLeft
    case downRight
}

enum CornerStyle {
    case none
    case xSmall
    case small
    case medium
    case circle(view: UIView)

    var radius: CGFloat {
        switch self {
        case .none:
            return 0
        case .xSmall:
            return 5
        case .small:
            return 10
        case .medium:
            return 20
        case .circle(let view):
            return view.frame.height / 2
        }
    }
}

fileprivate struct Constants {
    static let dimmedViewColor = UIColor.black.withAlphaComponent(0.8)

    static let animationTime = TimeInterval(0.2)
}

// MARK: - UIView
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

// MARK: - CALayer
extension CALayer {
    func addCorner(style: CornerStyle) {
        masksToBounds = true
        cornerRadius = style.radius
    }
}

// MARK: - UIViewController
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
            let viewToUse = self?.navigationController?.view == nil ? self?.view : self?.navigationController?.view

            let backgroundView = UIView(frame: viewToUse?.bounds ?? .zero)
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)

            let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
            activityIndicatorView.center = backgroundView.center
            activityIndicatorView.startAnimating()

            backgroundView.addSubview(activityIndicatorView)
            viewToUse?.addSubview(backgroundView)
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async { [weak self] in
            let viewToUse = self?.navigationController?.view == nil ? self?.view : self?.navigationController?.view

            guard let backgroundView = viewToUse?.subviews.last,
                backgroundView.subviews.first is UIActivityIndicatorView else {
                return
            }
            backgroundView.removeFromSuperview()
        }
    }
}

// MARK: - UITableView
extension UITableView {
    func reloadWithoutAnimation() {
        UIView.performWithoutAnimation {
            reloadData()
        }
    }
}

// MARK: - UICollectionView
extension UICollectionView {
    func reloadWithoutAnimation() {
        UIView.performWithoutAnimation {
            reloadData()
        }
    }
}

// MARK: - CGFloat
extension CGFloat {
    static let xxSmall = CGFloat(9)
    static let xSmall = CGFloat(12)
    static let small = CGFloat(15)
    static let normal = CGFloat(18)
    static let medium = CGFloat(20)
    static let large = CGFloat(25)
    static let xLarge = CGFloat(30)
    static let xxLarge = CGFloat(40)
    static let huge = CGFloat(100)
}

// MARK: - UIFont
extension UIFont {
    private func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits) ?? UIFontDescriptor()
        return UIFont(descriptor: descriptor, size: 0) // 0 size means it's unaffected
    }

    private func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let traits = [UIFontDescriptor.TraitKey.weight: weight]
        let descriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.traits: traits])
        return UIFont(descriptor: descriptor, size: 0) // 0 size means it's unaffected
    }

    static let xxSmall = UIFont.systemFont(ofSize: .xxSmall)
    static let xSmall = UIFont.systemFont(ofSize: .xSmall)
    static let small = UIFont.systemFont(ofSize: .small)
    static let normal = UIFont.systemFont(ofSize: .normal)
    static let medium = UIFont.systemFont(ofSize: .medium)
    static let large = UIFont.systemFont(ofSize: .large)
    static let xLarge = UIFont.systemFont(ofSize: .xLarge)
    static let xxLarge = UIFont.systemFont(ofSize: .xxLarge)
    static let huge = UIFont.systemFont(ofSize: .huge)

    var ultraLight: UIFont {
        return withWeight(.ultraLight)
    }

    var light: UIFont {
        return withWeight(.light)
    }

    var regular: UIFont {
        return withWeight(.regular)
    }

    var medium: UIFont {
        return withWeight(.medium)
    }

    var semibold: UIFont {
        return withWeight(.semibold)
    }

    var heavy: UIFont {
        return withWeight(.heavy)
    }

    var bold: UIFont {
        return withTraits(.traitBold)
    }

    var italic: UIFont {
        return withTraits(.traitItalic)
    }
}
