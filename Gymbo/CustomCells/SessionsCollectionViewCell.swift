//
//  SessionsCollectionViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/30/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionsCollectionViewCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normal.semibold
        return label
    }()

    private let deleteButton: CustomButton = {
        let button = CustomButton()
        let image = UIImage(named: "delete")
        button.setImage(image, for: .normal)
        return button
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .small
        label.numberOfLines = 0
        return label
    }()

    private var isEditing = false {
        didSet {
            deleteButton.isHidden = !isEditing

            if isEditing {
                let oddOrEven = Int.random(in: 1 ... 2)
                let transformAnim = CAKeyframeAnimation(keyPath: "transform")
                transformAnim.values = [NSValue(
                    caTransform3D: CATransform3DMakeRotation(0.02, 0.0, 0.0, 1.0)),
                                        NSValue(caTransform3D: CATransform3DMakeRotation(-0.02, 0.0, 0.0, 1))]
                transformAnim.autoreverses = true
                transformAnim.duration = oddOrEven == 1 ? 0.13 : 0.12
                transformAnim.repeatCount = .infinity
                layer.add(transformAnim, forKey: "transform")
            } else {
                layer.removeAllAnimations()
            }
        }
    }

    weak var sessionsCollectionViewCellDelegate: SessionsCollectionViewCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - Structs/Enums
private extension SessionsCollectionViewCell {
    struct Constants {
        static let transformScale = CGFloat(0.95)
    }
}

// MARK: - UICollectionViewCell Var/Funcs
extension SessionsCollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            if !isEditing {
                let action: Transform = isHighlighted ? .shrink : .inflate
                transform(type: action)
            }
        }
    }
}

// MARK: - ViewAdding
extension SessionsCollectionViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [titleLabel, deleteButton, infoLabel])
    }

    func setupViews() {
        backgroundColor = .white
        // Can't set layer.clipsToBounds to true without messing up shadow
        layer.addCorner(style: .small)
        addBorder(1, color: .lightGray)

        contentView.backgroundColor = .white
        // Need to do this because can't set layer.clipsToBounds to true
        contentView.layer.addCorner(style: .small)
        contentView.addBorder(1, color: .clear)
        contentView.clipsToBounds = true

        addShadow(direction: .downRight)

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -5),
            titleLabel.heightAnchor.constraint(equalToConstant: 22),

            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor),

            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            infoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension SessionsCollectionViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    private func transform(type: Transform) {
        UIView.animate(withDuration: .defaultAnimationTime,
                       delay: 0,
                       options: [.allowUserInteraction],
                       animations: { [weak self] in
            switch type {
            case .shrink:
                self?.transform = CGAffineTransform(scaleX: Constants.transformScale,
                                                    y: Constants.transformScale)
            case .inflate:
                self?.transform = CGAffineTransform.identity
            }
        })
    }

    func configure(dataModel: SessionsCollectionViewCellModel) {
        titleLabel.text = dataModel.title
        infoLabel.text = dataModel.info
        isEditing = dataModel.isEditing
    }

    @objc private func deleteButtonTapped(_ sender: Any) {
        Haptic.sendImpactFeedback(.heavy)
        sessionsCollectionViewCellDelegate?.delete(cell: self)
    }
}
