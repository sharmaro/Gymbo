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

// MARK: - Properties
class SessionsCollectionViewCell: UICollectionViewCell {
    class var reuseIdentifier: String {
        return String(describing: self)
    }

    private lazy var titleLabel = UILabel(frame: .zero)
    private lazy var deleteButton = CustomButton(frame: .zero)
    private lazy var infoTextView = UITextView(frame: .zero)

    private var isEditing = false {
        didSet {
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
                transform(type: action)
            }
        }
    }
}

// MARK: - ViewAdding
extension SessionsCollectionViewCell: ViewAdding {
    func addViews() {
        add(subViews: [titleLabel, deleteButton, infoTextView])
    }

    func setupViews() {
        backgroundColor = .white
        // Can't set layer.clipsToBounds to true without messing up shadow
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor

        contentView.backgroundColor = .white
        // Need to do this because can't set layer.clipsToBounds to true
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.clipsToBounds = true

        addShadow(direction: .downRight)

        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        let image = UIImage(named: "delete")
        deleteButton.setImage(image, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        infoTextView.font = .systemFont(ofSize: 14)
        infoTextView.textColor = .darkGray
        infoTextView.textContainerInset = .zero
        infoTextView.textContainer.lineFragmentPadding = 0
        infoTextView.textContainer.lineBreakMode = .byTruncatingTail
        infoTextView.isUserInteractionEnabled = false
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: infoTextView.topAnchor, constant: -5)
        ])

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            infoTextView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            infoTextView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            infoTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
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
        UIView.animate(withDuration: Constants.animationTime,
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
        infoTextView.text = dataModel.info
        isEditing = dataModel.isEditing
    }

    @objc private func deleteButtonTapped(_ sender: UIButton) {
        sessionsCollectionViewCellDelegate?.delete(cell: self)
    }
}
