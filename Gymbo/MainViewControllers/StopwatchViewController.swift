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

    private let userDefault = UserDefaults.standard

    private var centiSecInt = 0 {
        didSet {
            centiSecondLabel.text = String(format: "%02d", centiSecInt)
        }
    }

    private var secInt = 0 {
        didSet {
            secondLabel.text = String(format: "%02d", secInt)
        }
    }

    private var minInt = 0 {
        didSet {
            minuteLabel.text = String(format: "%02d", minInt)
        }
    }
}

// MARK: - Structs/Enums
private extension StopwatchViewController {
    struct Constants {
        static let CENTISECONDS_KEY = "centiseconds"
        static let SECONDS_KEY = "seconds"
        static let MINUTES_KEY = "minutes"

        static let timerInterval = TimeInterval(0.01)
    }

    enum StopwatchState: Int {
        case started = 0
        case stopped = 1
        case reset = 2
    }
}

// MARK: - UIViewController Var/Funcs
extension StopwatchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContainerView()
        setupStopWatchButtons()
        loadFromUserDefaults()
        registerForApplicationNotifications()
    }
}

// MARK: - Funcs
extension StopwatchViewController {
    private func setupContainerView() {
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = 20
    }

    private func setupStopWatchButtons() {
        startButton.tag = 0
        stopButton.tag = 1
        resetButton.tag = 2
        [startButton, stopButton, resetButton].forEach {
            $0?.titleColor = .white
            $0?.addCornerRadius(resetButton.bounds.width / 2)
        }
    }

    private func loadFromUserDefaults() {
        if let stopwatchStateInt = userDefault.object(forKey: UserDefaultKeys.STOPWATCH_STATE) as? Int,
            let oldState = StopwatchState(rawValue: stopwatchStateInt) {
            stopwatchState = oldState
            updateFromOldValues()
            updateFromOldState()
        } else {
            stopWatchInitialState()
        }
    }

    private func stopWatchInitialState() {
        startButton.makeInteractable()
        stopButton.makeUninteractable()
        resetButton.makeUninteractable()
    }

    private func updateStopWatchButtons(animated: Bool) {
        switch stopwatchState {
        case .started:
            startButton.makeUninteractable(animated: animated)
            stopButton.makeInteractable(animated: animated)
            resetButton.makeUninteractable(animated: animated)
        case .stopped:
            startButton.makeInteractable(animated: animated)
            stopButton.makeUninteractable(animated: animated)
            resetButton.makeInteractable(animated: animated)
        case .reset:
            startButton.makeInteractable(animated: animated)
            stopButton.makeUninteractable(animated: animated)
            resetButton.makeUninteractable(animated: animated)
        }
        updateStopWatchContent()
    }

    private func updateStopWatchContent() {
        switch stopwatchState {
        case .started:
            timer = Timer.scheduledTimer(timeInterval: Constants.timerInterval, target: self, selector: #selector(updateTimeLabels), userInfo: nil, repeats: true)
        case .stopped:
            timer?.invalidate()
        case .reset:
            minInt = 0
            secInt = 0
            centiSecInt = 0
        }
    }

    private func updateFromOldValues() {
        if let timeDictionary = userDefault.object(forKey: UserDefaultKeys.STOPWATCH_TIME_DICTIONARY) as? [String: Int] {
            centiSecInt = timeDictionary[Constants.CENTISECONDS_KEY] ?? 0
            secInt = timeDictionary[Constants.SECONDS_KEY] ?? 0
            minInt = timeDictionary[Constants.MINUTES_KEY] ?? 0
        }
    }

    private func updateFromOldState() {
        if stopwatchState == .started,
            let date = userDefault.object(forKey: UserDefaultKeys.STOPWATCH_DATE) as? Date {

            var oldTimeInCentiSecs = 0
            oldTimeInCentiSecs += centiSecInt
            oldTimeInCentiSecs += (secInt * 100)
            oldTimeInCentiSecs += (minInt * 6000)

            // Converting seconds from date to centiseconds
            let centiSecElapsed = Int(Date().timeIntervalSince(date) * 100) + oldTimeInCentiSecs
            centiSecInt = centiSecElapsed % 100

            let totalSeconds = centiSecElapsed / 100
            secInt = totalSeconds % 60
            minInt = totalSeconds / 60
        }
        updateStopWatchButtons(animated: false)
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
            updateStopWatchButtons(animated: true)
        }
    }
}

// MARK: - ApplicationStateObserving
extension StopwatchViewController: ApplicationStateObserving {
    func didEnterBackground(_ notification: Notification) {
        timer?.invalidate()
        let timeDictionary: [String: Int] = [
            Constants.CENTISECONDS_KEY: centiSecInt,
            Constants.SECONDS_KEY: secInt,
            Constants.MINUTES_KEY: minInt
        ]

        if stopwatchState == .started {
            userDefault.set(Date(), forKey: UserDefaultKeys.STOPWATCH_DATE)
        }
        userDefault.set(stopwatchState.rawValue, forKey: UserDefaultKeys.STOPWATCH_STATE)
        userDefault.set(timeDictionary, forKey: UserDefaultKeys.STOPWATCH_TIME_DICTIONARY)
    }

    func willEnterForeground(_ notification: Notification) {
        updateFromOldState()
    }
}
