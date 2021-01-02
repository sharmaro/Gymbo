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

// MARK: - Structs/Enums
private extension SessionsCVCell {
    struct Constants {
        static let transformScale = CGFloat(0.95)
    }
}

// MARK: - UICollectionViewCell Var/Funcs
extension SessionsCVCell {
    override var isHighlighted: Bool {
        didSet {
            if !isEditing {
                let action: Transform = isHighlighted ? .shrink : .inflate
                transform(type: action)
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
        contentView.addBorder(1, color: .dynamicDarkGray)
        contentView.addShadow(direction: .downRight)

        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        contentView.backgroundColor = .dynamicWhite
        contentView.layer.borderColor = UIColor.dynamicDarkGray.cgColor
        contentView.layer.shadowColor = UIColor.dynamicDarkGray.cgColor
        [titleLabel, infoLabel].forEach { $0.textColor = .dynamicBlack }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -5),

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
extension SessionsCVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
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
