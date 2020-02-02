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

struct SessionsCollectionViewCellModel {
    var title: String? = nil
    var info: String? = nil
}

class SessionsCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var deleteButton: CustomButton!
    @IBOutlet private weak var sessionTitleLabel: UILabel!
    @IBOutlet private weak var exercisesInfoTextView: UITextView!

    class var nib: UINib {
        return UINib(nibName: reuseIdentifier, bundle: nil)
    }

    class var reuseIdentifier: String {
        return String(describing: self)
    }

    weak var sessionsCollectionViewCellDelegate: SessionsCollectionViewCellDelegate?

    var isEditing: Bool = false {
        didSet {
            visualEffectView.isHidden = !isEditing
            deleteButton.isHidden = !isEditing

            if isEditing {
                let oddOrEven = Int.random(in: 1 ... 2)
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
}

// MARK: - UICollectionViewCell Funcs
extension SessionsCollectionViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        addShadow()
        setupVisualEffectView()
        setupRoundedContainerView()
        setupTextView()
    }
}

// MARK: - Funcs
extension SessionsCollectionViewCell {
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
        exercisesInfoTextView.textColor = .darkGray
        exercisesInfoTextView.textContainerInset = .zero
        exercisesInfoTextView.textContainer.lineFragmentPadding = 0
        exercisesInfoTextView.textContainer.lineBreakMode = .byTruncatingTail
    }

    func configure(dataModel: SessionsCollectionViewCellModel) {
        sessionTitleLabel.text = dataModel.title
        exercisesInfoTextView.text = dataModel.info
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        sessionsCollectionViewCellDelegate?.delete(cell: self)
    }
}
