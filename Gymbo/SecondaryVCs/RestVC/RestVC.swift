//
//  RestVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/13/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class RestVC: UIViewController {
    private let topContainerView = UIView()

    private let restLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a time below to rest!"
        label.textAlignment = .center
        label.font = .normal
        label.numberOfLines = 0
        return label
    }()

    private let addTimeButton = CustomButton()
    private let removeTimeButton = CustomButton()
    private let circleProgressView = CircleProgressView()
    private let pickerView = UIPickerView()

    private let mainButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start Timer"
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private var mainButtonState: MainButtonState = .startTimer {
        didSet {
            mainButton.title = mainButtonState.rawValue
            mainButton.set(backgroundColor: mainButtonState.backgroundColor())
        }
    }

    private var isTimerActive: Bool {
        startedSessionTimers?.restTimer?.isValid ?? false
    }

    var customDSAndD: RestDSAndD?
    var startedSessionTimers: StartedSessionTimers?
}

// MARK: - Structs/Enums
private extension RestVC {
    struct Constants {
        static let timeDelta = 5
        static let defaultRow = 11

        static let timeButtonSize = CGSize(width: 100, height: 30)
    }

    enum MainButtonState: String {
        case startTimer = "Start Timer"
        case done = "Done!"

        func backgroundColor() -> UIColor {
            switch self {
            case .startTimer:
                return .systemBlue
            case .done:
                return .systemGreen
            }
        }

        mutating func toggle() {
            self = self == .startTimer ? .done : .startTimer
        }
    }
}

// MARK: - UIViewController Var/Funcs
extension RestVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()

        if isTimerActive {
            mainButtonInteraction()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        startedSessionTimers?.startedSessionTimerDelegates?.removeLast()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension RestVC: ViewAdding {
    func setupNavigationBar() {
        title = "Rest"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }

    func addViews() {
        view.add(subviews: [topContainerView, circleProgressView, mainButton])
        topContainerView.add(subviews: [restLabel, addTimeButton, removeTimeButton])
        circleProgressView.add(subviews: [pickerView])
    }

    func setupViews() {
        [addTimeButton, removeTimeButton].forEach {
            $0.titleLabel?.font = .small
            $0.set(backgroundColor: .systemGray)
            $0.addCorner(style: .small)
            $0.isHidden = true
        }

        addTimeButton.title = "+ 5s"
        addTimeButton.addTarget(self, action: #selector(addTimeButtonTapped), for: .touchUpInside)

        removeTimeButton.title = "- 5s"
        removeTimeButton.addTarget(self, action: #selector(removeTimeButtonTapped), for: .touchUpInside)

        pickerView.dataSource = customDSAndD
        pickerView.delegate = customDSAndD
        pickerView.selectRow(Constants.defaultRow, inComponent: 0, animated: false)

        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        [view, topContainerView, circleProgressView].forEach {
            $0.backgroundColor = .primaryBackground
        }
        restLabel.textColor = .secondaryText
    }

    //swiftlint:disable:next function_body_length
    func addConstraints() {
        NSLayoutConstraint.activate([
            topContainerView.safeTop.constraint(
                equalTo: view.safeTop,
                constant: 15),
            topContainerView.safeLeading.constraint(
                equalTo: view.safeLeading,
                constant: 20),
            topContainerView.safeTrailing.constraint(
                equalTo: view.safeTrailing,
                constant: -20),
            topContainerView.bottom.constraint(
                equalTo: circleProgressView.top,
                constant: -15),
            topContainerView.height.constraint(equalToConstant: 30),

            restLabel.top.constraint(equalTo: topContainerView.top),
            restLabel.leading.constraint(equalTo: topContainerView.leading),
            restLabel.trailing.constraint(equalTo: topContainerView.trailing),
            restLabel.bottom.constraint(equalTo: topContainerView.bottom),

            addTimeButton.width.constraint(equalToConstant: Constants.timeButtonSize.width),
            addTimeButton.height.constraint(equalToConstant: Constants.timeButtonSize.height),
            addTimeButton.centerX.constraint(
                equalTo: topContainerView.centerX,
                constant: -65),
            addTimeButton.centerY.constraint(equalTo: topContainerView.centerY),

            removeTimeButton.width.constraint(equalToConstant: Constants.timeButtonSize.width),
            removeTimeButton.height.constraint(equalToConstant: Constants.timeButtonSize.height),
            removeTimeButton.centerX.constraint(
                equalTo: topContainerView.centerX,
                constant: 65),
            removeTimeButton.centerY.constraint(equalTo: topContainerView.centerY),

            circleProgressView.safeLeading.constraint(
                equalTo: view.safeLeading,
                constant: 20),
            circleProgressView.safeTrailing.constraint(
                equalTo: view.safeTrailing,
                constant: -20),
            circleProgressView.bottom.constraint(
                equalTo: mainButton.top,
                constant: -15),

            pickerView.top.constraint(equalTo: circleProgressView.top),
            pickerView.leading.constraint(equalTo: circleProgressView.leading),
            pickerView.trailing.constraint(equalTo: circleProgressView.trailing),
            pickerView.bottom.constraint(equalTo: circleProgressView.bottom),

            mainButton.safeLeading.constraint(
                equalTo: view.safeLeading,
                constant: 20),
            mainButton.safeTrailing.constraint(
                equalTo: view.safeTrailing,
                constant: -20),
            mainButton.safeBottom.constraint(
                equalTo: view.safeBottom,
                constant: -15),
            mainButton.height.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - Funcs
extension RestVC {
    private func showHideCustomViews() {
        pickerView.isHidden.toggle()
        circleProgressView.shouldHideText.toggle()

        restLabel.isHidden.toggle()
        addTimeButton.isHidden.toggle()
        removeTimeButton.isHidden.toggle()
    }

    private func mainButtonInteraction() {
        switch mainButtonState {
        case .startTimer:
            Haptic.sendSelectionFeedback()
            showHideCustomViews()

            if isTimerActive {
                let totalRestTime = startedSessionTimers?.totalRestTime ?? 0
                let restTimeRemaining = startedSessionTimers?.restTimeRemaining ?? 0

                circleProgressView.totalTimeText = totalRestTime > 0 ?
                    totalRestTime.minutesAndSecondsString :
                    0.minutesAndSecondsString
                circleProgressView.timeRemainingText = restTimeRemaining > 0 ?
                    restTimeRemaining.minutesAndSecondsString :
                    0.minutesAndSecondsString
                circleProgressView.startAnimation(duration: restTimeRemaining,
                                                  totalTime: totalRestTime,
                                                  timeRemaining: restTimeRemaining)
            } else {
                let selectedPickerRow = pickerView.selectedRow(inComponent: 0)
                let totalRestTime = customDSAndD?
                    .totalRestTime(for: selectedPickerRow) ?? 0
                startedSessionTimers?.totalRestTime = totalRestTime
                startedSessionTimers?.restTimeRemaining = totalRestTime

                circleProgressView.startAnimation(duration: totalRestTime)
                startedSessionTimers?.startedRestTimer(totalTime: totalRestTime)
            }
            mainButtonState = .done
        case .done:
            Haptic.sendNotificationFeedback(.success)
            circleProgressView.stopAnimation()
            startedSessionTimers?.stopRestTimer()
            dismiss(animated: true)
        }
    }

    private func changeTime(delta: Int) {
        Haptic.sendSelectionFeedback()
        startedSessionTimers?.totalRestTime += delta
        startedSessionTimers?.restTimeRemaining += delta
        updateAnimation()
    }

    private func updateAnimation() {
        let totalRestTime = startedSessionTimers?.totalRestTime ?? 0
        let restTimeRemaining = startedSessionTimers?.restTimeRemaining ?? 0
        circleProgressView.startAnimation(duration: restTimeRemaining,
                                          totalTime: totalRestTime,
                                          timeRemaining: restTimeRemaining)

        if restTimeRemaining <= 0 {
            startedSessionTimers?.stopRestTimer()
            circleProgressView.stopAnimation()
            dismiss(animated: true)
        }
    }

    @objc private func closeButtonTapped() {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
    }

    @objc private func addTimeButtonTapped() {
        changeTime(delta: Constants.timeDelta)
    }

    @objc private func removeTimeButtonTapped() {
        changeTime(delta: -Constants.timeDelta)
    }

    @objc private func mainButtonTapped(_ sender: Any) {
        mainButtonInteraction()
    }
}

// MARK: - StartedSessionTimerDelegate
extension RestVC: StartedSessionTimerDelegate {
    func totalRestTimeUpdated() {
        guard isViewLoaded,
              let startedSessionTimers = startedSessionTimers else {
            return
        }

        circleProgressView.totalTimeText = startedSessionTimers.totalRestTime > 0 ?
            startedSessionTimers.totalRestTime.minutesAndSecondsString :
            0.minutesAndSecondsString
    }

    func restTimeRemainingUpdated() {
        guard isViewLoaded,
              let startedSessionTimers = startedSessionTimers else {
            return
        }

        circleProgressView.timeRemainingText = startedSessionTimers.restTimeRemaining > 0 ?
            startedSessionTimers.restTimeRemaining.minutesAndSecondsString :
            0.minutesAndSecondsString
    }

    func ended() {
        circleProgressView.stopAnimation()
        dismiss(animated: true)
    }
}
