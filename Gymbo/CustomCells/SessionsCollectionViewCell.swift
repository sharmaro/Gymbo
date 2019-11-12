//
//  SessionsCollectionViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/30/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol SessionsCollectionViewCellDelegate: class {
    func delete(cell: SessionsCollectionViewCell)
}

class SessionsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var deleteButton: CustomButton!
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var workoutsInfoTextView: UITextView!

    weak var sessionsCollectionViewCellDelegate: SessionsCollectionViewCellDelegate?

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return "SessionsCollectionViewCell"
    }

    var isEditing: Bool = false {
        didSet {
            visualEffectView.isHidden = !isEditing
            deleteButton.isHidden = !isEditing

            if isEditing {
                let oddOrEven = Int.random(in: 1...2)
                let transformAnim = CAKeyframeAnimation(keyPath:"transform")
                transformAnim.values = [NSValue(caTransform3D: CATransform3DMakeRotation(0.02, 0.0, 0.0, 1.0)), NSValue(caTransform3D: CATransform3DMakeRotation(-0.02, 0.0, 0.0, 1))]
                transformAnim.autoreverses = true
                transformAnim.duration = oddOrEven == 1 ? 0.13 : 0.12
                transformAnim.repeatCount = .infinity
                layer.add(transformAnim, forKey: "transform")
            } else {
                layer.removeAllAnimations()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        setupVisualEffectView()
        setupRoundedContainerView()
        setupTextView()
    }

    private func setupVisualEffectView() {
        visualEffectView.layer.cornerRadius = visualEffectView.bounds.width / 2
        visualEffectView.layer.masksToBounds = true
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

    @IBAction func deleteButtonTapped(_ sender: Any) {
        if sender is CustomButton {
            sessionsCollectionViewCellDelegate?.delete(cell: self)
        }
    }
}
