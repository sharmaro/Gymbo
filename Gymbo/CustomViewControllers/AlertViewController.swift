//
//  AlertViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var leftButton: CustomButton!
    @IBOutlet private weak var rightButton: CustomButton!

    var alertTitle: String?
    var content: String?
    var leftButtonTitle = "Cancel"
    var rightButtonTitle = "Confirm"
    var leftButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
}
// MARK: - Structs/Enums
private extension SessionPreviewViewController {
    struct Constants {
    }
}

// MARK: - UIViewController Var/Funcs
extension AlertViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContentView()
        setupButtons()
        setupAlertView()
    }
}

// MARK: - Funcs
extension AlertViewController {
    func setupAlert(title: String = "Alert", content: String, leftButtonTitle: String = "Cancel", rightButtonTitle: String = "Confirm", leftButtonAction: (() -> Void)? = nil, rightButtonAction: @escaping () -> Void) {
        alertTitle = title
        self.content = content
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction
    }

    private func setupContentView() {
        contentView.roundCorner()
    }

    private func setupButtons() {
        leftButton.title = "Cancel"
        leftButton.add(backgroundColor: .systemRed)

        rightButton.title = "Confirm"
        rightButton.add(backgroundColor: .systemGreen)

        [leftButton, rightButton].forEach {
            $0?.titleFontSize = 15
            $0?.addCorner()
        }
    }

    private func setupAlertView() {
        titleLabel.text = alertTitle
        contentLabel.text = content
        leftButton.title = leftButtonTitle
        rightButton.title = rightButtonTitle
    }

    @IBAction func leftButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.leftButtonAction?()
        }
    }

    @IBAction func rightButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.rightButtonAction?()
        }
    }
}
