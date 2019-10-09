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
    @IBOutlet weak var centiSecondLabel: UILabel!
    @IBOutlet weak var startButton: CustomButton!
    @IBOutlet weak var stopButton: CustomButton!
    @IBOutlet weak var resetButton: CustomButton!

    private var stopwatchState = StopwatchState.stopped
    private var timer: Timer?

    private var centiSecInt: Int = 0 {
        didSet {
            centiSecondLabel.text = String(format: "%02d", centiSecInt)
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

    private enum StopwatchState: Int {
        case started = 0
        case stopped = 1
        case reset = 2
    }

    private struct Constants {
        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3

        static let timeInterval: TimeInterval = 0.01

        static let STOPWATCH_STATE_KEY: String = "stopwatchStateKey"
        static let DATE_KEY: String = "dateKey"

        static let TIME_DICT_KEY: String = "timeDictKey"
        static let CS_INT_KEY: String = "csIntKey"
        static let S_INT_KEY: String = "sIntKey"
        static let MIN_INT_KEY: String = "minIntKey"
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

        let userDefault = UserDefaults.standard
        if let stopwatchStateInt = userDefault.object(forKey: Constants.STOPWATCH_STATE_KEY) as? Int,
            let oldState = StopwatchState(rawValue: stopwatchStateInt) {
            stopwatchState = oldState
            updateFromOldValues()
            updateFromOldState()
        } else {
            stopWatchInitialState()
        }

        let notifCenter = NotificationCenter.default
        notifCenter.addObserver(self, selector: #selector(didEnterBackgroundNotification), name: UIApplication.didEnterBackgroundNotification, object: nil)
        notifCenter.addObserver(self, selector: #selector(willEnterForegroundNotification), name: UIApplication.willEnterForegroundNotification, object: nil)
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
        switch stopwatchState {
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
        switch stopwatchState {
        case .started:
            timer = Timer.scheduledTimer(timeInterval: Constants.timeInterval, target: self, selector: #selector(updateTimeLabels), userInfo: nil, repeats: true)
        case .stopped:
            timer?.invalidate()
        case .reset:
            minInt = 0
            secInt = 0
            centiSecInt = 0
        }
    }

    private func updateFromOldValues() {
        if let timeDict = UserDefaults.standard.object(forKey: Constants.TIME_DICT_KEY) as? [String: Int] {
            centiSecInt = timeDict[Constants.CS_INT_KEY] ?? 0
            secInt = timeDict[Constants.S_INT_KEY] ?? 0
            minInt = timeDict[Constants.MIN_INT_KEY] ?? 0
        }
    }

    private func updateFromOldState() {
        if stopwatchState == .started,
            let date = UserDefaults.standard.object(forKey: Constants.DATE_KEY) as? Date {
            let deciSecElapsed = Int(Date().timeIntervalSince(date) * 100)
            centiSecInt += deciSecElapsed % 100
            let totalSeconds = deciSecElapsed / 100
            secInt += totalSeconds % 60
            minInt += totalSeconds / 60
        }
        updateStopWatchButtons()
    }

    @objc private func updateTimeLabels() {
        if centiSecInt + 1 < 100 {
            centiSecInt += 1
        } else if secInt + 1 < 60 {
            centiSecInt = 0
            secInt += 1
        } else {
            centiSecInt = 0
            secInt = 0
            minInt += 1
        }
    }

    @IBAction func stopWatchButtonPressed(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 0: // Start button pressed
                stopwatchState = .started
            case 1: // Stop button pressed
                stopwatchState = .stopped
            case 2: // Reset button pressed
                stopwatchState = .reset
            default:
                fatalError("Unrecognized tag in stopWatchButtonPressed")
            }
            updateStopWatchButtons()
        }
    }
}

// MARK: - Notification Center funcs

extension StopwatchViewController {
    @objc private func didEnterBackgroundNotification() {
        timer?.invalidate()
        let userStandard = UserDefaults.standard
        let timeDict: [String: Int] = [
            Constants.CS_INT_KEY: centiSecInt,
            Constants.S_INT_KEY: secInt,
            Constants.MIN_INT_KEY: minInt
        ]

        if stopwatchState == .started {
            userStandard.set(Date(), forKey: Constants.DATE_KEY)
        }
        userStandard.set(stopwatchState.rawValue, forKey: Constants.STOPWATCH_STATE_KEY)
        userStandard.set(timeDict, forKey: Constants.TIME_DICT_KEY)
    }

    @objc private func willEnterForegroundNotification() {
        updateFromOldState()
    }
}
