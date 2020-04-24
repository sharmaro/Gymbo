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

    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var deleteButton: CustomButton = {
        let button = CustomButton(frame: .zero)
        let image = UIImage(named: "delete")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var infoTextView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .systemFont(ofSize: 14)
        textView.textColor = .darkGray
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byTruncatingTail
        textView.isUserInteractionEnabled = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()

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

// MARK: - Funcs
extension SessionsCollectionViewCell {
    private func setup() {
        addShadow(direction: .downRight)
        addMainViews()
        setupMainViewConstraints()
        setupRoundedCorners()
    }

    private func addMainViews() {
        backgroundColor = .white
        contentView.backgroundColor = .white
        addSubviews(views: [titleLabel, deleteButton, infoTextView])
    }

    private func setupMainViewConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            titleLabel.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            titleLabel.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: infoTextView.topAnchor, constant: -5)
        ])

        NSLayoutConstraint.activate([
            deleteButton.safeAreaLayoutGuide.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            deleteButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),
            deleteButton.heightAnchor.constraint(equalTo: deleteButton.widthAnchor)
        ])

        NSLayoutConstraint.activate([
            infoTextView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            infoTextView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            infoTextView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
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
