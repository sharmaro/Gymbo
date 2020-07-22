//
//  RestViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/13/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class RestViewController: UIViewController {
    private let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private let restLabel: UILabel = {
        let label = UILabel()
        label.text = "Choose a time below to rest!"
        label.textAlignment = .center
        label.textColor = .darkGray
        label.font = .normal
        label.numberOfLines = 0
        return label
    }()

    private let addTimeButton: CustomButton = {
        let button = CustomButton()
        button.title = "+ 5s"
        button.titleLabel?.font = .small
        button.add(backgroundColor: .systemGray)
        button.addCorner(style: .small)
        button.isHidden = true
        return button
    }()

    private let removeTimeButton: CustomButton = {
        let button = CustomButton()
        button.title = "- 5s"
        button.titleLabel?.font = .small
        button.add(backgroundColor: .systemGray)
        button.addCorner(style: .small)
        button.isHidden = true
        return button
    }()

    private let circleProgressView: CircleProgressView = {
        let view = CircleProgressView()
        view.backgroundColor = .white
        return view
    }()

    private let pickerView = UIPickerView()

    private let mainButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start Timer"
        button.add(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private var mainButtonState: MainButtonState = .startTimer {
        didSet {
            mainButton.title = mainButtonState.rawValue
            mainButton.add(backgroundColor: mainButtonState.backgroundColor())
        }
    }

    private var restTimes = [String]()

    var isTimerActive = false
    var startSessionTotalRestTime = 0
    var startSessionRestTimeRemaining = 0
    private var totalRestTime = 0 {
        didSet {
            guard isViewLoaded else {
                return
            }

            circleProgressView.totalTimeText = totalRestTime > 0 ?
            totalRestTime.getMinutesAndSecondsString() : 0.getMinutesAndSecondsString()
        }
    }
    private var restTimeRemaining = 0 {
        didSet {
            guard isViewLoaded else {
                return
            }

            circleProgressView.timeRemainingText = restTimeRemaining > 0 ?
            restTimeRemaining.getMinutesAndSecondsString() : 0.getMinutesAndSecondsString()
        }
    }

    weak var restTimerDelegate: RestTimerDelegate?
}

// MARK: - Structs/Enums
private extension RestViewController {
    struct Constants {
        static let title = "Rest"

        static let timeDelta = 5
        static let defaultRow = 11

        static let pickerRowHeight = CGFloat(38)

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

// MARK: - ViewAdding
extension RestViewController: ViewAdding {
    func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped))
    }

    func addViews() {
        view.add(subviews: [topContainerView, circleProgressView, mainButton])
        topContainerView.add(subviews: [restLabel, addTimeButton, removeTimeButton])
        circleProgressView.add(subviews: [pickerView])
    }

    func setupViews() {
        view.backgroundColor = .white

        addTimeButton.addTarget(self, action: #selector(addTimeButtonTapped), for: .touchUpInside)
        removeTimeButton.addTarget(self, action: #selector(removeTimeButtonTapped), for: .touchUpInside)

        createPickerViewData()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(Constants.defaultRow, inComponent: 0, animated: false)

        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            topContainerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            topContainerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            topContainerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            topContainerView.bottomAnchor.constraint(equalTo: circleProgressView.topAnchor, constant: -15),
            topContainerView.heightAnchor.constraint(equalToConstant: 30)
        ])

        restLabel.autoPinEdges(to: topContainerView)

        NSLayoutConstraint.activate([
            addTimeButton.widthAnchor.constraint(equalToConstant: Constants.timeButtonSize.width),
            addTimeButton.heightAnchor.constraint(equalToConstant: Constants.timeButtonSize.height),
            addTimeButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor, constant: -65),
            addTimeButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            removeTimeButton.widthAnchor.constraint(equalToConstant: Constants.timeButtonSize.width),
            removeTimeButton.heightAnchor.constraint(equalToConstant: Constants.timeButtonSize.height),
            removeTimeButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor, constant: 65),
            removeTimeButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            circleProgressView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            circleProgressView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            circleProgressView.bottomAnchor.constraint(equalTo: mainButton.topAnchor, constant: -15)
        ])

        pickerView.autoPinEdges(to: circleProgressView)

        NSLayoutConstraint.activate([
            mainButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            mainButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            mainButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            mainButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - UIViewController Var/Funcs
extension RestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()

        if isTimerActive {
            mainButtonInteraction()
        }
    }
}

// MARK: - Funcs
extension RestViewController {
    private func createPickerViewData() {
        for i in 1...120 {
            let timeString = (i * 5).getMinutesAndSecondsString()
            restTimes.append(timeString)
        }
    }

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
            Haptic.shared.sendSelectionFeedback()
            showHideCustomViews()

            if isTimerActive {
                totalRestTime = startSessionTotalRestTime
                restTimeRemaining = startSessionRestTimeRemaining

                circleProgressView.startAnimation(duration: restTimeRemaining, totalTime: totalRestTime, timeRemaining: restTimeRemaining)
            } else {
                let selectedPickerRow = pickerView.selectedRow(inComponent: 0)
                totalRestTime = restTimes[selectedPickerRow].getSecondsFromTime() ?? 0
                restTimeRemaining = totalRestTime

                circleProgressView.startAnimation(duration: restTimeRemaining)
                restTimerDelegate?.started(totalTime: restTimeRemaining)
            }
            mainButtonState = .done
        case .done:
            Haptic.shared.sendNotificationFeedback(.success)
            circleProgressView.stopAnimation()
            restTimerDelegate?.ended()
            dismiss(animated: true)
        }
    }

    private func updateAnimation() {
        circleProgressView.startAnimation(duration: restTimeRemaining, totalTime: totalRestTime, timeRemaining: restTimeRemaining)
        restTimerDelegate?.timeUpdated(totalTime: totalRestTime, timeRemaining: restTimeRemaining)

        if restTimeRemaining <= 0 {
            restTimerDelegate?.ended()
            circleProgressView.stopAnimation()
            dismiss(animated: true)
        }
    }

    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func addTimeButtonTapped() {
        Haptic.shared.sendSelectionFeedback()
        totalRestTime += Constants.timeDelta
        restTimeRemaining += Constants.timeDelta
        updateAnimation()
    }

    @objc private func removeTimeButtonTapped() {
        Haptic.shared.sendSelectionFeedback()
        totalRestTime -= Constants.timeDelta
        restTimeRemaining -= Constants.timeDelta
        updateAnimation()
    }

    @objc private func mainButtonTapped(_ sender: Any) {
        mainButtonInteraction()
    }
}

// MARK: - UIPickerViewDataSource
extension RestViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        hideSelectorLines()
        return 1
    }

    private func hideSelectorLines() {
        pickerView.subviews.forEach {
            $0.isHidden = $0.frame.height < 1.0
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        restTimes.count
    }
}

// MARK: - UIPickerViewDelegate
extension RestViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: pickerView.bounds.width, height: Constants.pickerRowHeight)))
        pickerLabel.text = restTimes[row]
        pickerLabel.textColor = .black
        pickerLabel.textAlignment = .center
        pickerLabel.font = .xLarge
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Constants.pickerRowHeight
    }
}

// MARK: - UpdateDelegate
extension RestViewController: UpdateDelegate {
    // Using StartSessionViewController's timer to update the time in this presented view controller
    func update() {
        restTimeRemaining -= 1
        if restTimeRemaining <= 0 {
            restTimerDelegate?.ended()
            circleProgressView.stopAnimation()
            dismiss(animated: true)
        }
    }
}
