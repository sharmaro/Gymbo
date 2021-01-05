//
//  ModalPickerVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ModalPickerVC: UIViewController {
    private let containerView = UIView()
    private let tabBarView = UIView()

    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TITLE"
        label.font = UIFont.medium.bold
        return label
    }()

    private var cancelButton: CustomButton = {
        let button = CustomButton()
        button.title = "Cancel"
        button.set(backgroundColor: .systemRed)
        button.addCorner(style: .small)
        return button
    }()

    private var selectButton: CustomButton = {
        let button = CustomButton()
        button.title = "Select"
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private let pickerView = UIPickerView()

    let items: [String]

    weak var delegate: ModalPickerDelegate?

    init(title: String, items: [String]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)

        self.titleLabel.text = title
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension ModalPickerVC {
    struct Constants {
        static let pickerItemHeight = CGFloat(40)
    }
}

// MARK: - UIViewController Var/Funcs
extension ModalPickerVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ModalPickerVC: ViewAdding {
    func addViews() {
        view.add(subviews: [containerView])
        containerView.add(subviews: [tabBarView, pickerView])
        tabBarView.add(subviews: [cancelButton, titleLabel, selectButton])
    }

    func setupViews() {
        containerView.addCorner(style: .small)

        cancelButton.addTarget(self,
                             action: #selector(cancelButtonTapped),
                             for: .touchUpInside)
        titleLabel.textAlignment = .center
        selectButton.addTarget(self,
                             action: #selector(selectButtonTapped),
                             for: .touchUpInside)

        pickerView.dataSource = self
        pickerView.delegate = self
    }

    func setupColors() {
        view.backgroundColor = .dimmedBackgroundBlack
        containerView.backgroundColor = .dynamicLightGray
        tabBarView.backgroundColor = .dynamicLightGray
        titleLabel.textColor = .dynamicBlack
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.safeAreaLayoutGuide.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.safeAreaLayoutGuide.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.safeAreaLayoutGuide.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            tabBarView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tabBarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: pickerView.topAnchor),
            tabBarView.heightAnchor.constraint(equalToConstant: 50),

            pickerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            cancelButton.topAnchor.constraint(equalTo: tabBarView.topAnchor,
                                              constant: 10),
            cancelButton.leadingAnchor.constraint(equalTo: tabBarView.leadingAnchor,
                                                  constant: 15),
            cancelButton.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor,
                                                 constant: -10),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: tabBarView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor,
                                                constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: selectButton.leadingAnchor,
                                                 constant: -15),
            titleLabel.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor),

            selectButton.topAnchor.constraint(equalTo: tabBarView.topAnchor,
                                            constant: 10),
            selectButton.trailingAnchor.constraint(equalTo: tabBarView.trailingAnchor,
                                                 constant: -15),
            selectButton.bottomAnchor.constraint(equalTo: tabBarView.bottomAnchor,
                                               constant: -10),
            selectButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            selectButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
    }
}

// MARK: - Funcs
extension ModalPickerVC {
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
extension ModalPickerVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        items.count
    }
}

// MARK: - UIPickerViewDelegate
extension ModalPickerVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView,
                    viewForRow row: Int,
                    forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel(frame: CGRect(origin: .zero,
                                                size: CGSize(width: pickerView.bounds.width,
                                                             height: 40)))
        pickerLabel.text = items[row]
        pickerLabel.textColor = .dynamicBlack
        pickerLabel.textAlignment = .center
        pickerLabel.font = UIFont.large.semibold
        return pickerLabel
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        Constants.pickerItemHeight
    }
}

protocol ModalPickerDelegate: class {
    func canceledSelection()
    func selected(row: Int)
}

extension ModalPickerDelegate {
    func canceledSelection() {}
}
