//
//  PickerVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class PickerVC: UIViewController {
    private let cancelButton: CustomButton = {
        let button = CustomButton(
            frame: CGRect(
                origin: .zero,
                size: Constants.barButtonSize
            )
        )
        button.title = "Cancel"
        button.titleLabel?.font = .small
        button.set(backgroundColor: .systemRed)
        button.addCorner(style: .small)
        return button
    }()

    private let selectButton: CustomButton = {
        let button = CustomButton(
            frame: CGRect(
                origin: .zero,
                size: Constants.barButtonSize
            )
        )
        button.title = "Select"
        button.titleLabel?.font = .small
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private let pickerView = UIPickerView()

    private let items: [String]

    weak var delegate: PickerDelegate?

    init(items: [String], title: String = "Select") {
        self.items = items
        super.init(nibName: nil, bundle: nil)

        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension PickerVC {
    enum Constants {
        static let barButtonSize = CGSize(width: 80, height: 30)
        static let pickerItemHeight = CGFloat(40)
    }
}

// MARK: - UIViewController Var/Funcs
extension PickerVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()
    }
}

// MARK: - ViewAdding
extension PickerVC: ViewAdding {
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectButton)
    }

    func addViews() {
        view.add(subviews: [pickerView])
    }

    func setupViews() {
        cancelButton.addTarget(self,
                             action: #selector(cancelButtonTapped),
                             for: .touchUpInside)
        selectButton.addTarget(self,
                             action: #selector(selectButtonTapped),
                             for: .touchUpInside)

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    func addConstraints() {
        pickerView.autoPinSafeEdges(to: view)
    }
}

// MARK: - Funcs
extension PickerVC {
    @objc private func cancelButtonTapped(_ sender: Any) {
        guard sender is CustomButton else {
            return
        }
        Haptic.sendSelectionFeedback()

        delegate?.canceledSelection()
        dismiss(animated: true)
    }

    @objc private func selectButtonTapped(_ sender: Any) {
        guard sender is CustomButton else {
            return
        }
        Haptic.sendSelectionFeedback()

        let row = pickerView.selectedRow(inComponent: 0)
        delegate?.selected(row: row)
        dismiss(animated: true)
    }
}

// MARK: - UIPickerViewDataSource
extension PickerVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        items.count
    }
}

// MARK: - UIPickerViewDelegate
extension PickerVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel(frame: CGRect(origin: .zero,
                                                size: CGSize(width: pickerView.bounds.width,
                                                             height: 40)))
        pickerLabel.text = items[row]
        pickerLabel.textColor = .primaryText
        pickerLabel.textAlignment = .center
        pickerLabel.font = UIFont.large.semibold
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Constants.pickerItemHeight
    }
}
