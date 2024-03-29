//
//  CircleProgressView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/15/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class CircleProgressView: UIView {
    private let totalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        return label
    }()

    private let timeRemainingLabel = UILabel()

    private let staticLayer = CAShapeLayer()
    private let animatedLayer = CAShapeLayer()
    private let basicAnimation = CABasicAnimation(keyPath: Constants.strokeKey)

    var totalTimeText = "" {
        didSet {
            totalTimeLabel.text = totalTimeText
        }
    }

    var timeRemainingText = "" {
        didSet {
            timeRemainingLabel.text = timeRemainingText
        }
    }

    var shouldHideText = true {
        didSet {
            totalTimeLabel.isHidden = shouldHideText
            timeRemainingLabel.isHidden = shouldHideText
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension CircleProgressView {
    enum Constants {
        static let strokeKey = "strokeEnd"
        static let animationKey = "progress"

        static let labelHeight = CGFloat(42)
        static let lineWidth = CGFloat(8)
        static let labelSpacing = CGFloat(30)
    }
}

// MARK: - UIView Var/Funcs
extension CircleProgressView {
    override func layoutSubviews() {
        super.layoutSubviews()

        /*
         Need to call this here because if autolayout is used to
         create CircleProgressView then on initialization the frame is .zero.
         */
        setupCircleProgressBar()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension CircleProgressView: ViewAdding {
    func addViews() {
        add(subviews: [totalTimeLabel, timeRemainingLabel])
    }

    func setupViews() {
        [totalTimeLabel, timeRemainingLabel].forEach {
            $0.textAlignment = .center
            $0.font = .xxLarge
            $0.isHidden = true
        }
    }

    func setupColors() {
        backgroundColor = .clear
        totalTimeLabel.textColor = .primaryText
        timeRemainingLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            totalTimeLabel.width.constraint(equalTo: width),
            totalTimeLabel.height.constraint(equalToConstant: Constants.labelHeight),
            totalTimeLabel.centerX.constraint(equalTo: centerX),
            totalTimeLabel.centerY.constraint(
                equalTo: centerY,
                constant: -Constants.labelSpacing),

            timeRemainingLabel.width.constraint(equalTo: width),
            timeRemainingLabel.height.constraint(equalToConstant: Constants.labelHeight),
            timeRemainingLabel.centerX.constraint(equalTo: centerX),
            timeRemainingLabel.centerY.constraint(
                equalTo: centerY,
                constant: Constants.labelSpacing)
        ])
    }
}

// MARK: - Funcs
extension CircleProgressView {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    private func setupCircleProgressBar() {
        /*
         Since this isn't always a square, the smallest bound is
         necessary for calculating the radius otherwise
         the circle will go out of bounds
         */
        let minimumBound = min(bounds.width, bounds.height)
        let radius = CGFloat(minimumBound / 2 * 0.96)

        let startAngle: CGFloat = .pi * 3 / 2
        let endAngle: CGFloat = -.pi / 2

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2),
                                        radius: radius,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: false)

        staticLayer.path = circularPath.cgPath
        staticLayer.fillColor = UIColor.clear.cgColor
        staticLayer.strokeColor = UIColor.systemGreen.cgColor
        staticLayer.lineWidth = Constants.lineWidth
        layer.addSublayer(staticLayer)

        animatedLayer.path = circularPath.cgPath
        animatedLayer.fillColor = UIColor.clear.cgColor
        animatedLayer.strokeColor = UIColor.darkGray.cgColor
        animatedLayer.lineWidth = Constants.lineWidth
        animatedLayer.strokeEnd = 0
        animatedLayer.lineCap = .round
        layer.addSublayer(animatedLayer)
    }

    func startAnimation(duration: Int, totalTime: Int = 0, timeRemaining: Int = 0) {
        let elapsedTime = totalTime.cgFloat - timeRemaining.cgFloat
        var strokeEnd = CGFloat(0)
        if totalTime > 0 {
            strokeEnd = elapsedTime / totalTime.cgFloat
        }

        if strokeEnd > 1 {
            strokeEnd = 1
            animatedLayer.removeAnimation(forKey: Constants.animationKey)
            animatedLayer.strokeEnd = strokeEnd
            return
        }

        animatedLayer.removeAnimation(forKey: Constants.animationKey)
        animatedLayer.strokeEnd = strokeEnd

        basicAnimation.fromValue = animatedLayer.strokeEnd
        basicAnimation.toValue = 1
        basicAnimation.duration = CFTimeInterval(duration)
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        animatedLayer.add(basicAnimation, forKey: Constants.animationKey)
    }

    func stopAnimation() {
        animatedLayer.removeAnimation(forKey: Constants.animationKey)
    }
}
