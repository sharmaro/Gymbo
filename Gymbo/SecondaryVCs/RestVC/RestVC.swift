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
            topContainerView.safeAreaLayoutGuide.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 15),
            topContainerView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            topContainerView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            topContainerView.bottomAnchor.constraint(
                equalTo: circleProgressView.topAnchor, constant: -15),
            topContainerView.heightAnchor.constraint(equalToConstant: 30),

            restLabel.topAnchor.constraint(equalTo: topContainerView.topAnchor),
            restLabel.leadingAnchor.constraint(equalTo: topContainerView.leadingAnchor),
            restLabel.trailingAnchor.constraint(equalTo: topContainerView.trailingAnchor),
            restLabel.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor),

            addTimeButton.widthAnchor.constraint(equalToConstant: Constants.timeButtonSize.width),
            addTimeButton.heightAnchor.constraint(equalToConstant: Constants.timeButtonSize.height),
            addTimeButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor, constant: -65),
            addTimeButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),

            removeTimeButton.widthAnchor.constraint(equalToConstant: Constants.timeButtonSize.width),
            removeTimeButton.heightAnchor.constraint(equalToConstant: Constants.timeButtonSize.height),
            removeTimeButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor, constant: 65),
            removeTimeButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),

            circleProgressView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            circleProgressView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            circleProgressView.bottomAnchor.constraint(
                equalTo: mainButton.topAnchor, constant: -15),

            pickerView.topAnchor.constraint(equalTo: circleProgressView.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: circleProgressView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: circleProgressView.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: circleProgressView.bottomAnchor),

            mainButton.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            mainButton.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            mainButton.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -15),
            mainButton.heightAnchor.constraint(equalToConstant: 45)
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

    private func changeTime(delta: Int) {
        Haptic.sendSelectionFeedback()
        startedSessionTimers?.totalRestTime += delta
        startedSessionTimers?.restTimeRemaining += delta
        updateAnimation()
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
