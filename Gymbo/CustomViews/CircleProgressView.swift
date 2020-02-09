//
//  CircleProgressView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/15/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

class CircleProgressView: UIView {
    // MARK: - Properties
    private var totalTimeLabel = UILabel()
    private var timeRemainingLabel = UILabel()

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

    // MARK: - UIView Var/Funcs
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Need to call this here because if autolayout is used to create CircleProgressView then on initialization the frame is .zero.
        setupCircleProgressBar()
    }
}

// MARK: - Structs/Enums
private extension CircleProgressView {
    struct Constants {
        static let strokeKey = "strokeEnd"
        static let animationKey = "progress"

        static let labelHeight = CGFloat(42)
        static let lineWidth = CGFloat(8)
        static let timeDelta = CGFloat(5)
        static let fontSize = CGFloat(40)
        static let labelSpacing = CGFloat(30)
    }
}

// MARK: - Funcs
extension CircleProgressView {
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        setupTimeLabels()
    }

    private func setupCircleProgressBar() {
        let radius = CGFloat(bounds.width / 2 * 0.96)

        let startAngle: CGFloat = .pi * 3 / 2
        let endAngle: CGFloat = -.pi / 2

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.width/2, y: bounds.height/2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

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

    private func setupTimeLabels() {
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textColor = .lightGray

        timeRemainingLabel.textColor = .darkGray

        [totalTimeLabel, timeRemainingLabel].forEach {
            $0.textAlignment = .center
            $0.font = UIFont.systemFont(ofSize: Constants.fontSize)
            $0.isHidden = true
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            totalTimeLabel.widthAnchor.constraint(equalTo: widthAnchor),
            totalTimeLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            totalTimeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            totalTimeLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: Constants.labelSpacing)
        ])

        NSLayoutConstraint.activate([
            timeRemainingLabel.widthAnchor.constraint(equalTo: widthAnchor),
            timeRemainingLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            timeRemainingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            timeRemainingLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -Constants.labelSpacing)
        ])
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