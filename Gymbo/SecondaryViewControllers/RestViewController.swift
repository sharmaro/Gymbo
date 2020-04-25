//
//  RestViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/13/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol RestTimerDelegate: class {
    func started(totalTime: Int)
    func timeUpdated(totalTime: Int, timeRemaining: Int)
    func ended()
}

// MARK: - Properties
class RestViewController: UIViewController {
    private var topContainerView = UIView(frame: .zero)
    private var restLabel = UILabel(frame: .zero)
    private var addTimeButton = CustomButton(frame: .zero)
    private var removeTimeButton = CustomButton(frame: .zero)

    private var circleProgressView = CircleProgressView(frame: .zero)
    private var pickerView = UIPickerView(frame: .zero)

    private var mainButton = CustomButton(frame: .zero)
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
    func addViews() {
        view.add(subViews: [topContainerView, circleProgressView, mainButton])
        topContainerView.add(subViews: [restLabel, addTimeButton, removeTimeButton])
        circleProgressView.add(subViews: [pickerView])
    }

    func setupViews() {
        view.backgroundColor = .white

        topContainerView.backgroundColor = .white

        restLabel.text = "Choose a time below to rest!"
        restLabel.textAlignment = .center
        restLabel.textColor = .darkGray
        restLabel.font = .medium
        restLabel.numberOfLines = 0

        addTimeButton.title = "+ 5s"
        addTimeButton.titleLabel?.font = .small
        addTimeButton.add(backgroundColor: .systemGray)
        addTimeButton.addCorner(style: .small)
        addTimeButton.isHidden = true
        addTimeButton.addTarget(self, action: #selector(addTimeButtonTapped), for: .touchUpInside)

        removeTimeButton.title = "- 5s"
        removeTimeButton.titleLabel?.font = .small
        removeTimeButton.add(backgroundColor: .systemGray)
        removeTimeButton.addCorner(style: .small)
        removeTimeButton.isHidden = true
        removeTimeButton.addTarget(self, action: #selector(removeTimeButtonTapped), for: .touchUpInside)

        circleProgressView.backgroundColor = .white

        createPickerViewData()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.selectRow(Constants.defaultRow, inComponent: 0, animated: false)

        mainButton.title = "Start Timer"
        mainButton.add(backgroundColor: .systemBlue)
        mainButton.addCorner(style: .small)
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
    private func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonTapped))
    }

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
        totalRestTime += Constants.timeDelta
        restTimeRemaining += Constants.timeDelta
        updateAnimation()
    }

    @objc private func removeTimeButtonTapped() {
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
        pickerLabel.font = .xxLarge
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return Constants.pickerRowHeight
    }
}

// MARK: - TempDelegate
extension RestViewController: TimeLabelDelegate {
    // Using StartSessionViewController's timer to update the time in this presented view controller
    func updateTimeLabel() {
        restTimeRemaining -= 1
        if restTimeRemaining <= 0 {
            // Do other clean up here
            // Special alert for finishing
            restTimerDelegate?.ended()
            circleProgressView.stopAnimation()
            dismiss(animated: true)
        }
    }
}
