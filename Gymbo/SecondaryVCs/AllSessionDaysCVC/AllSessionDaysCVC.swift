//
//  AllSessionDaysCVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionDaysCVC: UICollectionViewController {
    private let dateButton: CustomButton = {
        let barButtonSize = CGSize(width: 120, height: 30)
        let button = CustomButton(frame: CGRect(origin: .zero, size: barButtonSize))
        button.titleLabel?.font = UIFont.small.light
        button.set(backgroundColor: .secondaryBackground)
        button.addCorner(style: .small)
        return button
    }()

    var customDataSource: AllSessionDaysCVDS?
    var customDelegate: AllSessionDaysCVD?
}

// MARK: - UIViewController Var/Funcs
extension AllSessionDaysCVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
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
extension AllSessionDaysCVC: ViewAdding {
    func setupNavigationBar() {
        title = "Session Days"
        navigationItem.titleView = dateButton
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }

    func addViews() {
        view.add(subviews: [])
    }

    func setupViews() {
        dateButton.title = customDataSource?.date.formattedString(type: .short) ?? ""
        dateButton.sizeToFit()
        // Padding for text
        dateButton.frame.size.width += 15
        dateButton.addTarget(self,
                             action: #selector(dateButtonTapped),
                             for: .touchUpInside)

        collectionView.dataSource = customDataSource
        collectionView.delegate = customDelegate

        collectionView.alwaysBounceVertical = true
        collectionView.register(TwoLabelsCVCell.self,
                                forCellWithReuseIdentifier: TwoLabelsCVCell.reuseIdentifier)
    }

    func setupColors() {
        collectionView.backgroundColor = .primaryBackground
        dateButton.titleColor = .primaryText
    }
}

// MARK: - Funcs
extension AllSessionDaysCVC {
    @objc private func closeButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
    }

    @objc private func dateButtonTapped(_ sender: Any) {
        guard sender is CustomButton,
              let dataSource = customDataSource else {
            return
        }
        Haptic.sendSelectionFeedback()

        let items = dataSource.dates.map { $0.formattedString(type: .short) }
        let pickerVC = PickerVC(items: items,
                                title: "Select Date")
        pickerVC.delegate = self
        let mainNC = VCFactory.makeMainNC(rootVC: pickerVC,
                                          transitioningDelegate: self)
        navigationController?.present(mainNC, animated: true)
    }
}

// MARK: ListDataSource
extension AllSessionDaysCVC: ListDataSource {
}

// MARK: - ListDelegate
extension AllSessionDaysCVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard let session = customDataSource?.session(for: indexPath.row) else {
            return
        }
        Haptic.sendSelectionFeedback()

        let allSessionsDetailTVC = VCFactory.makeAllSessionsDetailTVC(session: session)
        navigationController?.pushViewController(allSessionsDetailTVC, animated: true)
    }
}

// MARK: - PickerDelegate
extension AllSessionDaysCVC: PickerDelegate {
    func selected(row: Int) {
        customDataSource?.selected(index: row)
        dateButton.title = customDataSource?.date.formattedString(type: .short) ?? ""
        collectionView.reloadAndScrollToTop()
    }
}
