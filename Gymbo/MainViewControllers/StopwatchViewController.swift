//
//  StopwatchViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class StopwatchViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var minuteLabel: UILabel!
    @IBOutlet private weak var secondLabel: UILabel!
    @IBOutlet private weak var centiSecondLabel: UILabel!
    @IBOutlet private weak var startButton: CustomButton!
    @IBOutlet private weak var stopButton: CustomButton!
    @IBOutlet private weak var resetButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

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
}

// MARK: - Structs/Enums
private extension StopwatchViewController {
    struct Constants {
        static let STOPWATCH_STATE = "stopwatchStateKey"
        static let DATE = "dateKey"
        static let TIME_DICT = "timeDictKey"
        static let CS_INT = "csIntKey"
        static let S_INT = "sIntKey"
        static let MIN_INT = "minIntKey"
    }

    enum StopwatchState: Int {
        case started = 0
        case stopped = 1
        case reset = 2
    }
}

// MARK: - UIViewController Funcs
extension StopwatchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 20

        startButton.tag = 0
        stopButton.tag = 1
        resetButton.tag = 2
        [startButton, stopButton, resetButton].forEach {
            $0?.titleColor = .white
            $0?.addCornerRadius(resetButton.bounds.width / 2)
        }

        let userDefault = UserDefaults.standard
        if let stopwatchStateInt = userDefault.object(forKey: Constants.STOPWATCH_STATE) as? Int,
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
}

// MARK: - Funcs
extension StopwatchViewController {
    private func stopWatchInitialState() {
        startButton.makeInteractable()
        stopButton.makeUninteractable()
        resetButton.makeUninteractable()
    }

    private func updateStopWatchButtons() {
        switch stopwatchState {
        case .started:
            startButton.makeUninteractable()
            stopButton.makeInteractable()
            resetButton.makeUninteractable()
        case .stopped:
            startButton.makeInteractable()
            stopButton.makeUninteractable()
            resetButton.makeInteractable()
        case .reset:
            startButton.makeInteractable()
            stopButton.makeUninteractable()
            resetButton.makeUninteractable()
        }
        updateStopWatchContent()
    }

    private func updateStopWatchContent() {
        switch stopwatchState {
        case .started:
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateTimeLabels), userInfo: nil, repeats: true)
        case .stopped:
            timer?.invalidate()
        case .reset:
            minInt = 0
            secInt = 0
            centiSecInt = 0
        }
    }

    private func updateFromOldValues() {
        if let timeDict = UserDefaults.standard.object(forKey: Constants.TIME_DICT) as? [String: Int] {
            centiSecInt = timeDict[Constants.CS_INT] ?? 0
            secInt = timeDict[Constants.S_INT] ?? 0
            minInt = timeDict[Constants.MIN_INT] ?? 0
        }
    }

    private func updateFromOldState() {
        if stopwatchState == .started,
            let date = UserDefaults.standard.object(forKey: Constants.DATE) as? Date {

            var oldTimeInCentiSecs: Int = 0
            oldTimeInCentiSecs += centiSecInt
            oldTimeInCentiSecs += (secInt * 100)
            oldTimeInCentiSecs += (minInt * 6000)

            let centiSecElapsed = Int(Date().timeIntervalSince(date) * 100) + oldTimeInCentiSecs
            centiSecInt = centiSecElapsed % 100

            let totalSeconds = centiSecElapsed / 100
            secInt = totalSeconds % 60
            minInt = totalSeconds / 60
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

    @objc private func didEnterBackgroundNotification() {
        timer?.invalidate()
        let userStandard = UserDefaults.standard
        let timeDict: [String: Int] = [
            Constants.CS_INT: centiSecInt,
            Constants.S_INT: secInt,
            Constants.MIN_INT: minInt
        ]

        if stopwatchState == .started {
            userStandard.set(Date(), forKey: Constants.DATE)
        }
        userStandard.set(stopwatchState.rawValue, forKey: Constants.STOPWATCH_STATE)
        userStandard.set(timeDict, forKey: Constants.TIME_DICT)
    }

    @objc private func willEnterForegroundNotification() {
        updateFromOldState()
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
