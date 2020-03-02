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
    var title: String?
    var info: String?
    var isEditing = false
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

    private var isEditing = false {
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

private extension SessionsCollectionViewCell {
    struct Constants {
        static let animationTime = TimeInterval(0.2)

        static let transformScale = CGFloat(0.95)
    }

    enum Transform {
        case shrink
        case inflate
    }
}

// MARK: - UICollectionViewCell Var/Funcs
extension SessionsCollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            if !isEditing {
                let action: Transform = isHighlighted ? .shrink : .inflate
                transform(condition: action)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        addShadow(direction: .downRight)
        setupVisualEffectView()
        setupRoundedCorners()
        setupTextView()
    }
}

// MARK: - Funcs
extension SessionsCollectionViewCell {
    private func setupVisualEffectView() {
        visualEffectView.roundCorner(radius: visualEffectView.bounds.width / 2)
    }

    private func setupRoundedCorners() {
        // Can't set layer.clipsToBounds to true without messing up shadow
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor

        // Need to do this because can't set layer.clipsToBounds to true
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true
    }

    private func setupTextView() {
        exercisesInfoTextView.textColor = .darkGray
        exercisesInfoTextView.textContainerInset = .zero
        exercisesInfoTextView.textContainer.lineFragmentPadding = 0
        exercisesInfoTextView.textContainer.lineBreakMode = .byTruncatingTail
    }

    private func transform(condition: Transform) {
        UIView.animate(withDuration: Constants.animationTime,
                       delay: 0,
                       options: [.allowUserInteraction],
                       animations: { [weak self] in
            switch condition {
            case .shrink:
                self?.transform = CGAffineTransform(scaleX: Constants.transformScale,
                                                    y: Constants.transformScale)
            case .inflate:
                self?.transform = CGAffineTransform.identity
            }
        })
    }

    func configure(dataModel: SessionsCollectionViewCellModel) {
        sessionTitleLabel.text = dataModel.title
        exercisesInfoTextView.text = dataModel.info
        isEditing = dataModel.isEditing
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        sessionsCollectionViewCellDelegate?.delete(cell: self)
    }
}
