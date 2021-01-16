//
//  SessionsCVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/30/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionsCVCell: UICollectionViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.normal.bold
        label.numberOfLines = 0
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
        label.font = UIFont.small.light
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

    var sessionName: String? {
        titleLabel.text
    }

    weak var sessionsCVCellDelegate: SessionsCVCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UICollectionViewCell Var/Funcs
extension SessionsCVCell {
    override var isHighlighted: Bool {
        didSet {
            if !isEditing {
                contentView.backgroundColor = isHighlighted ?
                    .selectedBackground : .secondaryBackground

                Transform.caseFromBool(bool: isHighlighted).transform(view: self)
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionsCVCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [titleLabel, deleteButton, infoLabel])
    }

    func setupViews() {
        contentView.layer.addCorner(style: .small)

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        contentView.backgroundColor = .secondaryBackground
        titleLabel.textColor = .primaryText
        infoLabel.textColor = .secondaryText
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.top.constraint(
                equalTo: contentView.top,
                constant: 5),
            titleLabel.leading.constraint(
                equalTo: contentView.leading,
                constant: 15),
            titleLabel.trailing.constraint(
                equalTo: deleteButton.leading,
                constant: -20),
            titleLabel.bottom.constraint(
                equalTo: infoLabel.top,
                constant: -5),

            deleteButton.top.constraint(
                equalTo: contentView.top,
                constant: 5),
            deleteButton.trailing.constraint(
                equalTo: contentView.trailing,
                constant: -5),
            deleteButton.width.constraint(equalToConstant: 20),
            deleteButton.height.constraint(equalTo: deleteButton.width),

            infoLabel.leading.constraint(
                equalTo: contentView.leading,
                constant: 15),
            infoLabel.trailing.constraint(
                equalTo: contentView.trailing,
                constant: -15),
            infoLabel.bottom.constraint(
                lessThanOrEqualTo: contentView.bottom,
                constant: -10)
        ])
    }
}

// MARK: - Funcs
extension SessionsCVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(dataModel: SessionsCVCellModel) {
        titleLabel.text = dataModel.title
        infoLabel.text = dataModel.info
        isEditing = dataModel.isEditing
    }

    @objc private func deleteButtonTapped(_ sender: Any) {
        Haptic.sendImpactFeedback(.heavy)
        sessionsCVCellDelegate?.delete(cell: self)
    }
}
