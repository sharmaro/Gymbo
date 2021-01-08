//
//  RestDSAndD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class RestDSAndD: NSObject {
    private var restTimes = [String]()

    override init() {
        super.init()
        createPickerViewData()
    }
}

// MARK: - Structs/Enums
extension RestDSAndD {
    private struct Constants {
        static let pickerRowHeight = CGFloat(38)
    }
}

// MARK: - Funcs
extension RestDSAndD {
    private func createPickerViewData() {
        for i in 1...120 {
            let timeString = (i * 5).minutesAndSecondsString
            restTimes.append(timeString)
        }
    }

    private func hideSelectorLines(in pickerView: UIPickerView) {
        pickerView.subviews.forEach {
            $0.isHidden = $0.frame.height < 1.0
        }
    }

    func totalRestTime(for row: Int) -> Int {
        restTimes[row].secondsFromTime ?? 0
    }
}

// MARK: - UIPickerViewDataSource
extension RestDSAndD: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        hideSelectorLines(in: pickerView)
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        restTimes.count
    }
}

// MARK: - UIPickerViewDelegate
extension RestDSAndD: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel(frame: CGRect(origin: .zero,
                                                size: CGSize(width: pickerView.bounds.width,
                                                             height: Constants.pickerRowHeight)))
        pickerLabel.text = restTimes[row]
        pickerLabel.textColor = .primaryText
        pickerLabel.textAlignment = .center
        pickerLabel.font = .xLarge
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Constants.pickerRowHeight
    }
}
