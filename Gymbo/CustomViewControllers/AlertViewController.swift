//
//  AlertViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AlertViewController: UIViewController {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var leftButton: CustomButton!
    @IBOutlet private weak var rightButton: CustomButton!

    var alertTitle: String?
    var content: String?
    var usesBothButtons: Bool?
    var leftButtonTitle: String?
    var rightButtonTitle: String?
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

        if usesBothButtons ?? true {
            leftButton.title = leftButtonTitle ?? ""
            rightButton.title = rightButtonTitle ?? ""
        } else {
            rightButton.title = rightButtonTitle ?? ""
        }
    }

    func setupAlert(title: String = "Alert", content: String, usesBothButtons: Bool = true, leftButtonTitle: String = "Cancel", rightButtonTitle: String = "Confirm", leftButtonAction: (() -> Void)? = nil, rightButtonAction: (() -> Void)? = nil) {
        alertTitle = title
        self.content = content
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction

        guard isViewLoaded, !usesBothButtons else {
            return
        }
        leftButton.removeFromSuperview()
    }

    @IBAction func leftButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        leftButtonAction?()
    }

    @IBAction func rightButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        rightButtonAction?()
    }
}
