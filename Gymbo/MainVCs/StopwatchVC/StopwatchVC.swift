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

    private var minInt = 0 {
        didSet {
            customDataSource?.minInt = minInt
            minuteLabel.text = String(format: "%02d", minInt)
        }
    }

    private var secInt = 0 {
        didSet {
            customDataSource?.secInt = secInt
            secondLabel.text = String(format: "%02d", secInt)
        }
    }

    private var centiSecInt = 0 {
        didSet {
            customDataSource?.centiSecInt = centiSecInt
            centiSecondLabel.text = String(format: "%02d", centiSecInt)
        }
    }

    var customDataSource: StopwatchTVDS?
    var customDelegate: StopwatchTVD?
}

// MARK: - Structs/Enums
private extension StopwatchVC {
    struct Constants {
        static let title = "Stopwatch"

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
        loadData()
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

        [minuteLabel, UIView.verticalSeparator, secondLabel,
         UIView.verticalSeparator, centiSecondLabel].forEach {
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

        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

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
        [view, tableView].forEach { $0?.backgroundColor = .dynamicWhite }
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
    private func loadData() {
        if let stopwatchStateInt = UserDefaults.standard.object(
            forKey: UserDefaultKeys.STOPWATCH_STATE) as? Int,
            let oldState = StopwatchState(rawValue: stopwatchStateInt) {
            stopwatchState = oldState
            customDataSource?.loadData()
            updateIntValues()
        } else {
            stopwatchState = .initial
        }
        updateStopWatchButtons()
    }

    private func updateStopWatchButtons() {
        switch stopwatchState {
        case .initial:
            lapAndResetButton.set(state: .disabled, animated: false)
            lapAndResetButton.title = "Lap"

            startAndStopButton.set(state: .enabled, animated: false)
        case .started:
            lapAndResetButton.set(state: .enabled, animated: true)
            lapAndResetButton.title = "Lap"

            startAndStopButton.title = "Stop"
            startAndStopButton.set(backgroundColor: .systemRed, animated: true)

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
            startAndStopButton.set(backgroundColor: .systemGreen, animated: true)

            lapAndResetButton.title = "Reset"

            timer?.invalidate()
        }
    }

    private func updateIntValues() {
        centiSecInt = customDataSource?.centiSecInt ?? 0
        secInt = customDataSource?.secInt ?? 0
        minInt = customDataSource?.minInt ?? 0
    }

    private func addLap() {
        let newLap = Lap(minutes: minInt,
                         seconds: secInt,
                         centiSeconds: centiSecInt)
        customDataSource?.add(lap: newLap)

        UIView.transition(with: tableView,
                          duration: .defaultAnimationTime,
                          options: .transitionCrossDissolve) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func resetStopwatch() {
        minInt = 0
        secInt = 0
        centiSecInt = 0

        customDataSource?.clearLapInfo()
        stopwatchState = .initial
        updateStopWatchButtons()
        tableView.reloadData()
    }

    private func renewConstraints() {
        guard isViewLoaded,
              let mainTBC = mainTBC else {
            return
        }

        let constantToUse = mainTBC.isSessionInProgress ?
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
                    addLap()
                } else if stopwatchState == .stopped {
                    // User selected 'Reset' functionality
                    resetStopwatch()
                }
            case 1: // startAndStop button tapped
                if stopwatchState == .started {
                    stopwatchState = .stopped
                } else if stopwatchState == .initial || stopwatchState == .stopped {
                    stopwatchState = .started
                }
                updateStopWatchButtons()
            default:
                fatalError("Unrecognized tag in stopWatchButtonTapped")
            }
        }
    }
}

// MARK: - ListDataSource
extension StopwatchVC: ListDataSource {
    func reloadData() {
        tableView.reloadData()
    }
}

// MARK: - ListDelegate
extension StopwatchVC: ListDelegate {
}

// MARK: - ApplicationStateObserving
extension StopwatchVC: ApplicationStateObserving {
    func didEnterBackground(_ notification: Notification) {
        timer?.invalidate()
        customDataSource?.saveData(stateRawValue: stopwatchState.rawValue)
    }

    func willEnterForeground(_ notification: Notification) {
        loadData()
    }
}

// MARK: - SessionProgressDelegate
extension StopwatchVC: SessionProgressDelegate {
    func sessionDidStart(_ session: Session?) {
        renewConstraints()
    }

    func sessionDidEnd(_ session: Session?, endType: EndType) {
        renewConstraints()
    }
}
