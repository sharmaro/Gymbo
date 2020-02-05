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
    private var circleView = UIView()
    private var totalTimeLabel = UILabel()
    private var restTimeRemainingLabel = UILabel()

    private let staticLayer = CAShapeLayer()
    private let animatedLayer = CAShapeLayer()
    private let basicAnimation = CABasicAnimation(keyPath: Constants.strokeKey)

    var totalTimeText = "" {
        didSet {
            totalTimeLabel.text = totalTimeText
        }
    }

    var restTimeText = "" {
        didSet {
            restTimeRemainingLabel.text = restTimeText
        }
    }

    var shouldHideText = true {
        didSet {
            totalTimeLabel.isHidden = shouldHideText
            restTimeRemainingLabel.isHidden = shouldHideText
        }
    }

    // MARK: - UIView Var/Funcs
    override init(frame: CGRect) {
        super.init(frame: frame)

        guard frame.width == frame.height else {
            fatalError("Cannot initiate a CircleProgressView with a rectangular view.")
        }
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
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
    }
}

// MARK: - Funcs
extension CircleProgressView {
    private func setup() {
        backgroundColor = .clear

        createCircleProgressBar()
        addTotalRestTimeLabel()
        addRestTimeRemainingLabel()
    }

    private func createCircleProgressBar() {
        let circleSize = CGSize(width: bounds.width, height: bounds.height)

        circleView = UIView(frame: CGRect(origin: .zero, size: circleSize))
        circleView.backgroundColor = .clear
        addSubview(circleView)

        let radius = CGFloat(circleView.bounds.width / 2 * 0.96)

        let startAngle: CGFloat = .pi * 3 / 2
        let endAngle: CGFloat = -.pi / 2

        let circularPath = UIBezierPath(arcCenter: CGPoint(x: circleSize.width/2, y: circleSize.height/2), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)

        staticLayer.path = circularPath.cgPath
        staticLayer.fillColor = UIColor.clear.cgColor
        staticLayer.strokeColor = UIColor.systemGreen.cgColor
        staticLayer.lineWidth = Constants.lineWidth
        circleView.layer.addSublayer(staticLayer)

        animatedLayer.path = circularPath.cgPath
        animatedLayer.fillColor = UIColor.clear.cgColor
        animatedLayer.strokeColor = UIColor.darkGray.cgColor
        animatedLayer.lineWidth = Constants.lineWidth
        animatedLayer.strokeEnd = 0
        animatedLayer.lineCap = .round
        circleView.layer.addSublayer(animatedLayer)
    }

    private func addTotalRestTimeLabel() {
        totalTimeLabel = UILabel(frame: .zero)
        totalTimeLabel.text = "00:00"
        totalTimeLabel.textAlignment = .center
        totalTimeLabel.font = UIFont.systemFont(ofSize: Constants.fontSize)
        totalTimeLabel.textColor = .lightGray
        totalTimeLabel.isHidden = true
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(totalTimeLabel)

        NSLayoutConstraint.activate([
            totalTimeLabel.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            totalTimeLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            totalTimeLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            totalTimeLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 30)
        ])
    }

    private func addRestTimeRemainingLabel() {
        restTimeRemainingLabel = UILabel(frame: .zero)
        restTimeRemainingLabel.textAlignment = .center
        restTimeRemainingLabel.font = UIFont.systemFont(ofSize: Constants.fontSize)
        restTimeRemainingLabel.textColor = .darkGray
        restTimeRemainingLabel.isHidden = true
        restTimeRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        circleView.addSubview(restTimeRemainingLabel)

        NSLayoutConstraint.activate([
            restTimeRemainingLabel.widthAnchor.constraint(equalTo: circleView.widthAnchor),
            restTimeRemainingLabel.heightAnchor.constraint(equalToConstant: Constants.labelHeight),
            restTimeRemainingLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            restTimeRemainingLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -30)
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
