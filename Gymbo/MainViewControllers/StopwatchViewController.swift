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
    private lazy var timeStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var minuteLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 100)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var secondLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 100)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var centiSecondLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "00"
        label.font = UIFont.systemFont(ofSize: 100)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var lapAndResetButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.title = "Lap"
        button.add(backgroundColor: .systemGray)
        button.addCorner(radius: 5)
        button.tag = 0
        button.addTarget(self, action: #selector(stopWatchButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var startAndStopButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        button.title = "Start"
        button.add(backgroundColor: .systemGreen)
        button.addCorner(radius: 5)
        button.tag = 1
        button.addTarget(self, action: #selector(stopWatchButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

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

// MARK: - UIViewController Var/Funcs
extension StopwatchViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupNavigationBar()
        addMainViews()
        setupTimeStackView()
        setupTableView()
        setupButtonsStackView()
        loadFromUserDefaults()
        registerForApplicationStateNotifications()
        registerForSessionProgressNotifications()
    }
}

// MARK: - Funcs
extension StopwatchViewController {
    private func setupNavigationBar() {
        title = "Stopwatch"
    }

    private func addMainViews() {
        view.addSubviews(views: [timeStackView, tableView, buttonsStackView])
    }

    private func setupTimeStackView() {
        NSLayoutConstraint.activate([
            timeStackView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            timeStackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            timeStackView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            timeStackView.heightAnchor.constraint(equalToConstant: Constants.timeStackViewHeight)
        ])

        let verticalSeparatorView1 = createVerticalSeparatorView()
        let verticalSeparatorView2 = createVerticalSeparatorView()
        [minuteLabel, verticalSeparatorView1, secondLabel, verticalSeparatorView2, centiSecondLabel].forEach {
            timeStackView.addArrangedSubview($0)
        }

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
    }

    private func setupTableView() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor, constant: 15),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -15)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.register(StopwatchTableViewCell.self, forCellReuseIdentifier: StopwatchTableViewCell.reuseIdentifier)
    }

    private func setupButtonsStackView() {
        NSLayoutConstraint.activate([
            buttonsStackView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            buttonsStackView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            buttonsStackView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonsStackViewHeight)
        ])

        [lapAndResetButton, startAndStopButton].forEach {
            buttonsStackView.addArrangedSubview($0)
        }
        buttonsStackView.layoutIfNeeded()
    }

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

    @objc private func stopWatchButtonPressed(_ sender: Any) {
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
                fatalError("Unrecognized tag in stopWatchButtonPressed")
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
            fatalError("Couldn't dequeue cell of type StopwatchTableViewCell")
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

// MARK: - SessionProgressObserving
extension StopwatchViewController: SessionProgressObserving {
    func sessionDidStart(_ notification: Notification) {
        // Increase bottom view bottom constraint
    }

    func sessionDidEnd(_ notification: Notification) {
    }
}
