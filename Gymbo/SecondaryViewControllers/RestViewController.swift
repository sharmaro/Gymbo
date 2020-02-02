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

class RestViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var restTimesPickerView: UIPickerView!
    @IBOutlet weak var animationProgressContainerView: UIView!
    @IBOutlet weak var mainButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private lazy var circleProgressView: CircleProgressView = {
        return CircleProgressView(frame: CGRect(origin: .zero, size: CGSize(width: animationProgressContainerView.bounds.width, height: animationProgressContainerView.bounds.width)))
    }()

    private lazy var addTimeButton: CustomButton = {
        let size = CGSize(width: 100, height: 30)

        let button = CustomButton(frame: .zero)
        button.title = "+ 5s"
        button.add(backgroundColor: .systemGray)
        button.addCornerRadius()
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addTimeButtonTapped), for: .touchUpInside)
        topContainerView.insertSubview(button, belowSubview: restLabel)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size.width),
            button.heightAnchor.constraint(equalToConstant: size.height),
            button.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor, constant: -65),
            button.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ])
        return button
    }()

    private lazy var removeTimeButton: CustomButton = {
        let size = CGSize(width: 100, height: 30)

        let button = CustomButton(frame: .zero)
        button.title = "- 5s"
        button.add(backgroundColor: .systemGray)
        button.addCornerRadius()
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(removeTimeButtonTapped), for: .touchUpInside)
        topContainerView.insertSubview(button, belowSubview: restLabel)

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: size.width),
            button.heightAnchor.constraint(equalToConstant: size.height),
            button.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor, constant: 65),
            button.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ])
        return button
    }()

    private var mainButtonState: MainButtonState = .startTimer {
        didSet {
            mainButton.title = mainButtonState.rawValue
            mainButton.add(backgroundColor: mainButtonState.backgroundColor())
        }
    }

    private var timer: Timer?
    private var restTimes = [String]()

    var isTimerActive = false
    var startSessionTotalRestTime = 0
    var startSessionRestTimeRemaining = 0
    private var totalRestTime = 0 {
        didSet {
            circleProgressView.totalTimeText = totalRestTime > 0 ?
            totalRestTime.getMinutesAndSecondsString() : 0.getMinutesAndSecondsString()
        }
    }
    private var restTimeRemaining = 0 {
        didSet {
            circleProgressView.restTimeText = restTimeRemaining > 0 ?
            restTimeRemaining.getMinutesAndSecondsString() : 0.getMinutesAndSecondsString()
        }
    }

    weak var dimmedViewDelegate: DimmedViewDelegate?
    weak var restTimerDelegate: RestTimerDelegate?
}

// MARK: - Structs/Enums
private extension RestViewController {
    struct Constants {
        static let timeDelta = 5
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

// MARK: - UIViewController Funcs
extension RestViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.prefersLargeTitles = false

        setupContainerView()
        createPickerViewData()
        setupPickerView()
        setupMainButton()
        animationProgressContainerView.insertSubview(circleProgressView, belowSubview: restTimesPickerView)

        if isTimerActive {
            mainButton.sendActions(for: .touchUpInside)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        dimmedViewDelegate?.removeDimmedView(animated: true)
    }
}

// MARK: - Funcs
extension RestViewController {
    private func setupContainerView() {
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
    }

    private func createPickerViewData() {
        for i in 1...120 {
            let timeString = (i * 5).getMinutesAndSecondsString()
            restTimes.append(timeString)
        }
    }

    private func setupPickerView() {
        restTimesPickerView.dataSource = self
        restTimesPickerView.delegate = self
        restTimesPickerView.selectRow(11, inComponent: 0, animated: false)
    }

    private func setupMainButton() {
        mainButton.title = "Start Timer"
        mainButton.add(backgroundColor: .systemBlue)
        mainButton.addCornerRadius()
    }

    private func showHideCustomViews() {
        restTimesPickerView.isHidden.toggle()
        circleProgressView.shouldHideText.toggle()
        restLabel.isHidden.toggle()
        addTimeButton.isHidden.toggle()
        removeTimeButton.isHidden.toggle()
    }

    @objc private func updateTimeLabel() {
        restTimeRemaining -= 1

        if restTimeRemaining <= 0 {
            /// Do other clean up here
            /// Special alert for finishing
            timer?.invalidate()
            restTimerDelegate?.ended()
            circleProgressView.stopAnimation()
            dismiss(animated: true)
        }
    }

    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func mainButtonTapped(_ sender: Any) {
        switch mainButtonState {
        case .startTimer:
            showHideCustomViews()

            if isTimerActive {
                totalRestTime = startSessionTotalRestTime
                restTimeRemaining = startSessionRestTimeRemaining

                circleProgressView.startAnimation(duration: restTimeRemaining, totalTime: totalRestTime, timeRemaining: restTimeRemaining)
            } else {
                let selectedPickerRow = restTimesPickerView.selectedRow(inComponent: 0)
                totalRestTime = restTimes[selectedPickerRow].getSecondsFromTime() ?? 0
                restTimeRemaining = totalRestTime

                circleProgressView.startAnimation(duration: restTimeRemaining)
                restTimerDelegate?.started(totalTime: restTimeRemaining)
            }

            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)

            mainButtonState = .done
        case .done:
            circleProgressView.stopAnimation()
            restTimerDelegate?.ended()
            dismiss(animated: true)
        }
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

    private func updateAnimation() {
        circleProgressView.startAnimation(duration: restTimeRemaining, totalTime: totalRestTime, timeRemaining: restTimeRemaining)
        restTimerDelegate?.timeUpdated(totalTime: totalRestTime, timeRemaining: restTimeRemaining)

        if restTimeRemaining <= 0 {
            timer?.invalidate()
            restTimerDelegate?.ended()
            circleProgressView.stopAnimation()
            dismiss(animated: true)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension RestViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        hideSelectorLines()
        return 1
    }

    private func hideSelectorLines() {
        restTimesPickerView.subviews.forEach {
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
        let pickerLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: pickerView.bounds.width, height: 25)))
        pickerLabel.text = restTimes[row]
        pickerLabel.textColor = .black
        pickerLabel.textAlignment = .center
        pickerLabel.font = UIFont.systemFont(ofSize: 18)
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
}
