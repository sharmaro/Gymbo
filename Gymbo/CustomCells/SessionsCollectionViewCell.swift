//
//  SessionsCollectionViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/30/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class SessionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var workoutsInfoTextView: UITextView!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return "SessionsCollectionViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupRoundedContainerView()
        setupTextView()
    }

    private func setupRoundedContainerView() {
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.lightGray.cgColor
    }

    private func setupTextView() {
        workoutsInfoTextView.textColor = .darkGray
        workoutsInfoTextView.textContainerInset = .zero
        workoutsInfoTextView.textContainer.lineFragmentPadding = 0
        workoutsInfoTextView.textContainer.lineBreakMode = .byTruncatingTail
    }

    func clearLabels() {
        sessionTitleLabel.text?.removeAll()
        workoutsInfoTextView.text?.removeAll()
    }
}
