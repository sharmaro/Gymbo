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
    private var dateButton: CustomButton = {
        let barButtonSize = CGSize(width: 120, height: 30)
        let button = CustomButton(frame: CGRect(origin: .zero, size: barButtonSize))
        button.titleLabel?.font = UIFont.small.light
        button.set(backgroundColor: .systemGray)
        button.addCorner(style: .small)
        return button
    }()

    var customDataSource: AllSessionDaysCVDS?
    var customDelegate: AllSessionDaysCVD?
}

// MARK: - Structs/Enums
private extension AllSessionDaysCVC {
    struct Constants {
    }
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
    }

    func addViews() {
        view.add(subviews: [])
    }

    func setupViews() {
        dateButton.title = customDataSource?.date.formattedString(type: .short) ?? ""
        dateButton.sizeToFit()
        // Padding for text
        dateButton.frame.size.width += 15
        dateButton.addTarget(self, action: #selector(dateButtonTapped),
                             for: .touchUpInside)

        collectionView.dataSource = customDataSource
        collectionView.delegate = customDelegate

        collectionView.register(TwoLabelsCVCell.self,
                                forCellWithReuseIdentifier: TwoLabelsCVCell.reuseIdentifier)
    }

    func setupColors() {
        collectionView.backgroundColor = .dynamicWhite
    }
}

// MARK: - Funcs
extension AllSessionDaysCVC {
    @objc private func dateButtonTapped(_ sender: Any) {
        guard sender is CustomButton,
              let dataSource = customDataSource else {
            return
        }

        let items = dataSource.dates.map { $0.formattedString(type: .short) }
        let modalPickerVC = ModalPickerVC(title: "Select Date",
                                          items: items)
        modalPickerVC.delegate = self
        modalPickerVC.modalPresentationStyle = .overFullScreen
        navigationController?.present(modalPickerVC, animated: true)
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

// MARK: - ModalPickerDelegate
extension AllSessionDaysCVC: ModalPickerDelegate {
    func selected(row: Int) {
        customDataSource?.selected(index: row)
        dateButton.title = customDataSource?.date.formattedString(type: .short) ?? ""
        collectionView.reloadAndScrollToTop()
    }
}
