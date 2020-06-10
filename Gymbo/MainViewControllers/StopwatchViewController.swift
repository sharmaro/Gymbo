//
//  StopwatchViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchViewController: UIViewController {
    private var timeStackView = UIStackView(frame: .zero)
    private var minuteLabel = UILabel(frame: .zero)
    private var secondLabel = UILabel(frame: .zero)
    private var centiSecondLabel = UILabel(frame: .zero)

    private var tableView = UITableView(frame: .zero)

    private var buttonsStackView = UIStackView(frame: .zero)
    private var lapAndResetButton = CustomButton(frame: .zero)
    private var startAndStopButton = CustomButton(frame: .zero)

    private var buttonsStackViewBottomConstraint: NSLayoutConstraint?
    private var didViewAppear = false

    private var stopwatchState = StopwatchState.initial
    private var timer: Timer?

    private let userDefault = UserDefaults.standard

    private var minInt = 0 {
        didSet {
            minuteLabel.text = String(format: "%02d", minInt)
        }
    }

    private var secInt = 0 {
        didSet {
            secondLabel.text = String(format: "%02d", secInt)
        }
    }

    private var centiSecInt = 0 {
        didSet {
            centiSecondLabel.text = String(format: "%02d", centiSecInt)
        }
    }

    private var laps: [Lap]?
    private var previousLap: Lap?
    private var fastestLap: Lap?
    private var slowestLap: Lap?
    private var newLap: Lap {
        var lap = Lap(minutes: minInt, seconds: secInt, centiSeconds: centiSecInt)

        if let previousLap = previousLap {
            lap.minutes = abs(previousLap.minutes - minInt)
            lap.seconds = abs(previousLap.seconds - secInt)
            lap.centiSeconds = abs(previousLap.centiSeconds - centiSecInt)
        }

        if let fastestLap = fastestLap {
            if lap.totalTime <= fastestLap.totalTime {
                self.fastestLap = lap
            }
        } else {
            self.fastestLap = lap
        }

        if let slowestLap = slowestLap {
            if lap.totalTime >= slowestLap.totalTime {
                self.slowestLap = lap
            }
        } else {
            self.slowestLap = lap
        }
        return lap
    }
}

// MARK: - Structs/Enums
private extension StopwatchViewController {
    struct Constants {
        static let CENTISECONDS_KEY = "centiseconds"
        static let SECONDS_KEY = "seconds"
        static let MINUTES_KEY = "minutes"
        static let LAPS_KEY = "laps"
        static let LAPS_INFO_KEy = "lapsInfo"

        static let timerInterval = TimeInterval(0.01)

        static let timeStackViewHeight = CGFloat(100)
        static let buttonsStackViewHeight = CGFloat(45)
        static let sessionStartedConstraintConstant = CGFloat(-50)
        static let sessionEndedConstraintConstant = CGFloat(-15)
    }

    // Codable is for encoding/decoding
    struct Lap: Codable {
        var minutes: Int
        var seconds: Int
        var centiSeconds: Int

        var totalTime: Int {
            let minutesConverted = minutes * 6000
            let secondsConverted = seconds * 100
            return minutesConverted + secondsConverted + centiSeconds
        }

        var text: String {
            let minuteText = String(format: "%02d", minutes)
            let secondsText = String(format: "%02d", seconds)
            let centiSecondsText = String(format: "%02d", centiSeconds)
            return "\(minuteText):\(secondsText).\(centiSecondsText)"
        }
    }

    enum StopwatchState: Int {
        case initial = 0
        case stopped = 1
        case started = 2
    }
}

// MARK: - ViewAdding
extension StopwatchViewController: ViewAdding {
    func setupNavigationBar() {
        title = "Stopwatch"
    }

    func addViews() {
        view.add(subviews: [timeStackView, tableView, buttonsStackView])

        let verticalSeparatorView1 = createVerticalSeparatorView()
        let verticalSeparatorView2 = createVerticalSeparatorView()
        [minuteLabel, verticalSeparatorView1, secondLabel, verticalSeparatorView2, centiSecondLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            timeStackView.addArrangedSubview($0)
        }

        [lapAndResetButton, startAndStopButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            buttonsStackView.addArrangedSubview($0)
        }
    }

    func setupViews() {
        view.backgroundColor = .white

        timeStackView.alignment = .center
        timeStackView.distribution = .fill

        [minuteLabel, secondLabel, centiSecondLabel].forEach {
            $0.text = "00"
            $0.font = .huge
            $0.textAlignment = .center
            $0.minimumScaleFactor = 0.1
            $0.numberOfLines = 0
            $0.adjustsFontSizeToFitWidth = true
        }

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.register(StopwatchTableViewCell.self, forCellReuseIdentifier: StopwatchTableViewCell.reuseIdentifier)

        buttonsStackView.alignment = .fill
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 15

        lapAndResetButton.title = "Lap"
        lapAndResetButton.add(backgroundColor: .systemGray)
        lapAndResetButton.addCorner(style: .small)
        lapAndResetButton.tag = 0
        lapAndResetButton.addTarget(self, action: #selector(stopWatchButtonTapped), for: .touchUpInside)

        startAndStopButton.title = "Start"
        startAndStopButton.add(backgroundColor: .systemGreen)
        startAndStopButton.addCorner(style: .small)
        startAndStopButton.tag = 1
        startAndStopButton.addTarget(self, action: #selector(stopWatchButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            timeStackView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            timeStackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            timeStackView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            timeStackView.heightAnchor.constraint(equalToConstant: Constants.timeStackViewHeight)
        ])

        let verticalSeparatorView1 = timeStackView.arrangedSubviews[1]
        let verticalSeparatorView2 = timeStackView.arrangedSubviews[3]
        NSLayoutConstraint.activate([
            secondLabel.widthAnchor.constraint(equalTo: minuteLabel.widthAnchor, multiplier: 1),
            centiSecondLabel.widthAnchor.constraint(equalTo: minuteLabel.widthAnchor, multiplier: 1),
            minuteLabel.heightAnchor.constraint(equalTo: timeStackView.heightAnchor),
            secondLabel.heightAnchor.constraint(equalTo: timeStackView.heightAnchor),
            centiSecondLabel.heightAnchor.constraint(equalTo: timeStackView.heightAnchor),
            verticalSeparatorView1.widthAnchor.constraint(equalToConstant: 1),
            verticalSeparatorView1.heightAnchor.constraint(equalToConstant: Constants.timeStackViewHeight / 2),
            verticalSeparatorView2.widthAnchor.constraint(equalToConstant: 1),
            verticalSeparatorView2.heightAnchor.constraint(equalToConstant: Constants.timeStackViewHeight / 2)
        ])
        timeStackView.layoutIfNeeded()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor)
        ])

        buttonsStackViewBottomConstraint = buttonsStackView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: Constants.sessionEndedConstraintConstant)
        buttonsStackViewBottomConstraint?.isActive = true
        NSLayoutConstraint.activate([
            buttonsStackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            buttonsStackView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonsStackViewHeight)
        ])
    }
}

// MARK: - UIViewController Var/Funcs
extension StopwatchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()
        loadFromUserDefaults()
        registerForApplicationStateNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        didViewAppear = true
        renewConstraints()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        didViewAppear = false
    }
}

// MARK: - Funcs
extension StopwatchViewController {
    private func loadFromUserDefaults() {
        if let stopwatchStateInt = userDefault.object(forKey: UserDefaultKeys.STOPWATCH_STATE) as? Int,
            let oldState = StopwatchState(rawValue: stopwatchStateInt) {
            stopwatchState = oldState
            updateFromOldValues()
            updateFromOldState()
        } else {
            stopwatchState = .initial
            updateStopWatchButtons(animated: false)
        }
    }

    private func createVerticalSeparatorView() -> UIView {
        let verticalSeparatorView = UIView(frame: .zero)
        verticalSeparatorView.backgroundColor = .systemGray
        verticalSeparatorView.translatesAutoresizingMaskIntoConstraints = false

        return verticalSeparatorView
    }

    private func updateStopWatchButtons(animated: Bool) {
        switch stopwatchState {
        case .initial:
            lapAndResetButton.makeUninteractable()
            lapAndResetButton.title = "Lap"

            startAndStopButton.makeInteractable()
        case .started:
            lapAndResetButton.makeInteractable()
            lapAndResetButton.title = "Lap"

            startAndStopButton.title = "Stop"
            startAndStopButton.add(backgroundColor: .systemRed)

            timer = Timer.scheduledTimer(timeInterval: Constants.timerInterval, target: self, selector: #selector(updateTimeLabels), userInfo: nil, repeats: true)
            if let timer = timer {
                // Allows it to update the navigation bar.
                RunLoop.main.add(timer, forMode: .common)
            }
        case .stopped:
            startAndStopButton.title = "Start"
            startAndStopButton.add(backgroundColor: .systemGreen)

            lapAndResetButton.title = "Reset"

            timer?.invalidate()
        }
    }

    private func updateFromOldValues() {
        if let timeDictionary = userDefault.object(forKey: UserDefaultKeys.STOPWATCH_TIME_DICTIONARY) as? [String: Int] {
            centiSecInt = timeDictionary[Constants.CENTISECONDS_KEY] ?? 0
            secInt = timeDictionary[Constants.SECONDS_KEY] ?? 0
            minInt = timeDictionary[Constants.MINUTES_KEY] ?? 0
        }

        loadLaps()
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

    @objc private func stopWatchButtonTapped(_ sender: Any) {
        if let button = sender as? UIButton {
            switch button.tag {
            case 0: // lapAndReset button tapped
                if stopwatchState == .started {
                    // User selected `Lap` functionality
                    if laps == nil {
                        laps = [newLap]
                    } else {
                        laps?.insert(newLap, at: 0)
                    }

                    previousLap = Lap(minutes: minInt, seconds: secInt, centiSeconds: centiSecInt)

                    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: true)
                } else if stopwatchState == .stopped {
                    // User selected `Reset` functionality
                    minInt = 0
                    secInt = 0
                    centiSecInt = 0

                    previousLap = nil
                    fastestLap = nil
                    slowestLap = nil

                    stopwatchState = .initial
                    updateStopWatchButtons(animated: true)

                    laps?.removeAll()
                    tableView.reloadData()
                }
            case 1: // startAndStop button tapped
                if stopwatchState == .started {
                    stopwatchState = .stopped
                } else if stopwatchState == .initial || stopwatchState == .stopped {
                    stopwatchState = .started
                }
                updateStopWatchButtons(animated: true)
            default:
                fatalError("Unrecognized tag in stopWatchButtonTapped")
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension StopwatchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StopwatchTableViewCell.reuseIdentifier, for: indexPath) as? StopwatchTableViewCell else {
            presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
            return UITableViewCell()
        }

        guard let laps = laps else {
            fatalError("Laps array is nil")
        }

        let lap = laps[indexPath.row]
        cell.configure(descriptionText: "Lap \(laps.count - indexPath.row)", valueText: lap.text)

        if laps.count > 2 {
            cell.checkLapComparison(timeToCheck: lap.totalTime, fastestTime: fastestLap?.totalTime ?? 0, slowestTime: slowestLap?.totalTime ?? 0)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension StopwatchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(withDuration: 0.2) {
            cell.alpha = 1
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

        saveLaps()
    }

    private func saveLaps() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode(laps) {
            defaults.set(encodedData, forKey: Constants.LAPS_KEY)
        }

        let lapsInfo = [previousLap, fastestLap, slowestLap]
        if let encodedData = try? encoder.encode(lapsInfo) {
            defaults.set(encodedData, forKey: Constants.LAPS_INFO_KEy)
        }
    }

    private func loadLaps() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        if let data = defaults.data(forKey: Constants.LAPS_KEY),
            let laps = try? decoder.decode(Array<Lap>.self, from: data) {
            self.laps = laps
        } else {
            laps = nil
        }

        if let data = defaults.data(forKey: Constants.LAPS_INFO_KEy),
            let lapsInfo = try? decoder.decode(Array<Lap>.self, from: data) {
            previousLap = lapsInfo[0]
            fastestLap = lapsInfo[1]
            slowestLap = lapsInfo[2]
        }

        tableView.reloadData()
    }

    func willEnterForeground(_ notification: Notification) {
        updateFromOldState()
        loadLaps()
    }
}

// MARK: - SessionProgressDelegate
extension StopwatchViewController: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?) {
        renewConstraints()
    }
}

// MARK: - SessionStateConstraintsUpdating
extension StopwatchViewController: SessionStateConstraintsUpdating {
    func renewConstraints() {
        guard let mainTabBarController = mainTabBarController else {
            return
        }

        if mainTabBarController.isSessionInProgress {
            buttonsStackViewBottomConstraint?.constant = Constants.sessionStartedConstraintConstant
        } else {
            buttonsStackViewBottomConstraint?.constant = Constants.sessionEndedConstraintConstant
        }

        if didViewAppear {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.view.layoutIfNeeded()
            }
        }
    }
}
