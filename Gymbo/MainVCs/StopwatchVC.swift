//
//  StopwatchVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchVC: UIViewController {
    private let timeStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()

    private let minuteLabel = UILabel()
    private let secondLabel = UILabel()
    private let centiSecondLabel = UILabel()

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 15
        return stackView
    }()

    private let lapAndResetButton: CustomButton = {
        let button = CustomButton()
        button.title = "Lap"
        button.set(backgroundColor: .systemGray)
        button.addCorner(style: .small)
        button.tag = 0
        return button
    }()

    private let startAndStopButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start"
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        button.tag = 1
        return button
    }()

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

    private var lapDataModel = LapDataModel()
}

// MARK: - Structs/Enums
private extension StopwatchVC {
    struct Constants {
        static let title = "Stopwatch"
        static let CENTISECONDS_KEY = "centiseconds"
        static let SECONDS_KEY = "seconds"
        static let MINUTES_KEY = "minutes"
        static let LAPS_KEY = "laps"
        static let LAPS_INFO_KEy = "lapsInfo"

        static let timerInterval = TimeInterval(0.01)

        static let timeStackViewHeight = CGFloat(100)
        static let buttonsStackViewHeight = CGFloat(45)
        static let sessionStartedConstraintConstant = CGFloat(-64)
        static let sessionEndedConstraintConstant = CGFloat(-20)
        static let cellSpacingToButtons = CGFloat(15)
    }

    enum StopwatchState: Int {
        case initial
        case stopped
        case started
    }
}

// MARK: - UIViewController Var/Funcs
extension StopwatchVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension StopwatchVC: ViewAdding {
    func setupNavigationBar() {
        title = Constants.title
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
        tableView.register(StopwatchTVCell.self,
                           forCellReuseIdentifier: StopwatchTVCell.reuseIdentifier)

        tableView.contentInset.bottom =
            Constants.buttonsStackViewHeight +
            (-1 * Constants.sessionEndedConstraintConstant) +
            Constants.cellSpacingToButtons

        lapAndResetButton.addTarget(self, action: #selector(stopWatchButtonTapped), for: .touchUpInside)
        startAndStopButton.addTarget(self, action: #selector(stopWatchButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        view.backgroundColor = .dynamicWhite
        tableView.backgroundColor = .dynamicWhite
        [minuteLabel, secondLabel, centiSecondLabel].forEach { $0.textColor = .dynamicBlack }
    }

    //swiftlint:disable:next function_body_length
    func addConstraints() {
        let verticalSeparatorView1 = timeStackView.arrangedSubviews[1]
        let verticalSeparatorView2 = timeStackView.arrangedSubviews[3]

        buttonsStackViewBottomConstraint =
            buttonsStackView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Constants.sessionEndedConstraintConstant)
        buttonsStackViewBottomConstraint?.isActive = true

        NSLayoutConstraint.activate([
            timeStackView.safeAreaLayoutGuide.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor),
            timeStackView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            timeStackView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            timeStackView.heightAnchor.constraint(equalToConstant: Constants.timeStackViewHeight),

            secondLabel.widthAnchor.constraint(equalTo: minuteLabel.widthAnchor, multiplier: 1),
            centiSecondLabel.widthAnchor.constraint(equalTo: minuteLabel.widthAnchor, multiplier: 1),
            minuteLabel.heightAnchor.constraint(equalTo: timeStackView.heightAnchor),
            secondLabel.heightAnchor.constraint(equalTo: timeStackView.heightAnchor),
            centiSecondLabel.heightAnchor.constraint(equalTo: timeStackView.heightAnchor),
            verticalSeparatorView1.widthAnchor.constraint(equalToConstant: 1),
            verticalSeparatorView1.heightAnchor.constraint(
                equalToConstant: Constants.timeStackViewHeight / 2),
            verticalSeparatorView2.widthAnchor.constraint(equalToConstant: 1),
            verticalSeparatorView2.heightAnchor.constraint(
                equalToConstant: Constants.timeStackViewHeight / 2),

            tableView.topAnchor.constraint(equalTo: timeStackView.bottomAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            buttonsStackView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 15),
            buttonsStackView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -15),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.buttonsStackViewHeight)
        ])
        timeStackView.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension StopwatchVC {
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
            lapAndResetButton.set(state: .disabled, animated: animated)
            lapAndResetButton.title = "Lap"

            startAndStopButton.set(state: .enabled, animated: animated)
        case .started:
            lapAndResetButton.set(state: .enabled, animated: animated)
            lapAndResetButton.title = "Lap"

            startAndStopButton.title = "Stop"
            startAndStopButton.set(backgroundColor: .systemRed)

            timer = Timer.scheduledTimer(timeInterval: Constants.timerInterval,
                                         target: self,
                                         selector: #selector(updateTimeLabels),
                                         userInfo: nil,
                                         repeats: true)
            if let timer = timer {
                // Allows it to update the navigation bar.
                RunLoop.main.add(timer, forMode: .common)
            }
        case .stopped:
            startAndStopButton.title = "Start"
            startAndStopButton.set(backgroundColor: .systemGreen)

            lapAndResetButton.title = "Reset"

            timer?.invalidate()
        }
    }

    private func updateFromOldValues() {
        if let timeDictionary =
            userDefault.object(forKey: UserDefaultKeys.STOPWATCH_TIME_DICTIONARY) as? [String: Int] {
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

    private func saveLaps() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode(lapDataModel.laps) {
            defaults.set(encodedData, forKey: Constants.LAPS_KEY)
        }

        let lapsInfo = [lapDataModel.previousLap,
                        lapDataModel.fastestLap,
                        lapDataModel.slowestLap]
        if let encodedData = try? encoder.encode(lapsInfo) {
            defaults.set(encodedData, forKey: Constants.LAPS_INFO_KEy)
        }
    }

    private func loadLaps() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        if let data = defaults.data(forKey: Constants.LAPS_KEY),
            let laps = try? decoder.decode(Array<Lap>.self, from: data) {
            lapDataModel.laps = laps
        } else {
            lapDataModel.laps = nil
        }

        if let data = defaults.data(forKey: Constants.LAPS_INFO_KEy),
            let lapsInfo = try? decoder.decode(Array<Lap>.self, from: data) {
            lapDataModel.previousLap = lapsInfo[0]
            lapDataModel.fastestLap = lapsInfo[1]
            lapDataModel.slowestLap = lapsInfo[2]
        }

        tableView.reloadData()
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
        Haptic.sendSelectionFeedback()
        if let button = sender as? UIButton {
            switch button.tag {
            case 0: // lapAndReset button tapped
                if stopwatchState == .started {
                    // User selected 'Lap' functionality
                    let newLap = lapDataModel.newLap(minutes: minInt,
                                                     seconds: secInt,
                                                     centiSeconds: centiSecInt)
                    if lapDataModel.laps == nil {
                        lapDataModel.laps = [newLap]
                    } else {
                        lapDataModel.laps?.insert(newLap, at: 0)
                    }

                    lapDataModel.previousLap = Lap(minutes: minInt,
                                                   seconds: secInt,
                                                   centiSeconds: centiSecInt)

                    UIView.transition(with: tableView,
                                      duration: .defaultAnimationTime,
                                      options: .transitionCrossDissolve,
                                      animations: { [weak self] in
                        self?.tableView.reloadData()
                    })
                } else if stopwatchState == .stopped {
                    // User selected 'Reset' functionality
                    minInt = 0
                    secInt = 0
                    centiSecInt = 0

                    lapDataModel.previousLap = nil
                    lapDataModel.fastestLap = nil
                    lapDataModel.slowestLap = nil

                    stopwatchState = .initial
                    updateStopWatchButtons(animated: true)

                    lapDataModel.laps?.removeAll()
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
extension StopwatchVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        lapDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: StopwatchTVCell.reuseIdentifier,
                for: indexPath) as? StopwatchTVCell else {
            fatalError("Could not dequeue \(StopwatchTVCell.reuseIdentifier)")
        }

        guard let laps = lapDataModel.laps else {
            fatalError("Laps array is nil")
        }

        let lap = laps[indexPath.row]
        cell.configure(descriptionText: "Lap \(laps.count - indexPath.row)", valueText: lap.text)

        if laps.count > 2 {
            cell.checkLapComparison(timeToCheck: lap.totalTime,
                                    fastestTime: lapDataModel.fastestLap?.totalTime ?? 0,
                                    slowestTime: lapDataModel.slowestLap?.totalTime ?? 0)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StopwatchVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        lapDataModel.heightForRow(at: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(withDuration: .defaultAnimationTime) {
            cell.alpha = 1
        }
    }
}

// MARK: - ApplicationStateObserving
extension StopwatchVC: ApplicationStateObserving {
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

    func willEnterForeground(_ notification: Notification) {
        updateFromOldState()
        loadLaps()
    }
}

// MARK: - SessionProgressDelegate
extension StopwatchVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?) {
        renewConstraints()
    }
}

// MARK: - SessionStateConstraintsUpdating
extension StopwatchVC: SessionStateConstraintsUpdating {
    func renewConstraints() {
        guard isViewLoaded,
              let mainTBC = mainTBC else {
            return
        }

        let constantToUse =
            mainTBC.isSessionInProgress ?
            Constants.sessionStartedConstraintConstant :
            Constants.sessionEndedConstraintConstant
        buttonsStackViewBottomConstraint?.constant = constantToUse

        if didViewAppear {
            UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
                self?.tableView.contentInset.bottom =
                    Constants.buttonsStackViewHeight +
                    (-1 * constantToUse) +
                    Constants.cellSpacingToButtons
                self?.view.layoutIfNeeded()
            }
        }
    }
}
