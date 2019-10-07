//
//  StopwatchViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class StopwatchViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var minuteLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var millisecondLabel: UILabel!
    @IBOutlet weak var startButton: CustomButton!
    @IBOutlet weak var stopButton: CustomButton!
    @IBOutlet weak var resetButton: CustomButton!

    private var stopWatchStatus = StopWatchStatus.stopped
    private var timer: Timer?

    private var msInt: Int = 0 {
        didSet {
            millisecondLabel.text = String(format: "%02d", msInt)
        }
    }

    private var secInt: Int = 0 {
        didSet {
            secondLabel.text = String(format: "%02d", secInt)
        }
    }

    private var minInt: Int = 0 {
        didSet {
            minuteLabel.text = String(format: "%02d", minInt)
        }
    }

    private enum StopWatchStatus {
        case started
        case stopped
        case reset
    }

    private struct Constants {
        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = false

        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 20

        startButton.tag = 0
        stopButton.tag = 1
        resetButton.tag = 2
        [startButton, stopButton, resetButton].forEach {
            $0?.textColor = .white
            $0?.borderColor = .white
            $0?.borderWidth = 0
            $0?.addCornerRadius(resetButton.bounds.width / 2)
        }

        stopWatchInitialState()
    }

    private func stopWatchInitialState() {
        startButton.isEnabled = true
        startButton.alpha = Constants.activeAlpha

        stopButton.isEnabled = false
        stopButton.alpha = Constants.inactiveAlpha

        resetButton.isEnabled = false
        resetButton.alpha = Constants.inactiveAlpha
    }

    private func updateStopWatchButtons() {
        switch stopWatchStatus {
        case .started:
            startButton.isEnabled = false
            startButton.alpha = Constants.inactiveAlpha

            stopButton.isEnabled = true
            stopButton.alpha = Constants.activeAlpha

            resetButton.isEnabled = false
            resetButton.alpha = Constants.inactiveAlpha
        case .stopped:
            startButton.isEnabled = true
            startButton.alpha = Constants.activeAlpha

            stopButton.isEnabled = false
            stopButton.alpha = Constants.inactiveAlpha

            resetButton.isEnabled = true
            resetButton.alpha = Constants.activeAlpha
        case .reset:
            startButton.isEnabled = true
            startButton.alpha = Constants.activeAlpha

            stopButton.isEnabled = false
            stopButton.alpha = Constants.inactiveAlpha

            resetButton.isEnabled = false
            resetButton.alpha = Constants.inactiveAlpha
        }
        updateStopWatchContent()
    }

    private func updateStopWatchContent() {
        switch stopWatchStatus {
        case .started:
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimeLabels), userInfo: nil, repeats: true)
        case .stopped:
            timer?.invalidate()
        case .reset:
            minInt = 0
            secInt = 0
            msInt = 0
        }
    }

    @objc private func updateTimeLabels() {
        if msInt + 1 < 100 {
            msInt += 1
        } else if secInt + 1 < 60 {
            msInt = 0
            secInt += 1
        } else {
            msInt = 0
            secInt = 0
            minInt += 1
        }
    }

    @IBAction func stopWatchButtonPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 0: // Start button pressed
                stopWatchStatus = .started
            case 1: // Stop button pressed
                stopWatchStatus = .stopped
            case 2: // Reset button pressed
                stopWatchStatus = .reset
            default:
                fatalError("Unrecognized tag in stopWatchButtonPressed")
            }
            updateStopWatchButtons()
        }
    }
}
