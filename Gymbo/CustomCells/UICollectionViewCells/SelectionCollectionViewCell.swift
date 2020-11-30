//
//  SelectionCollectionViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionCollectionViewCell: UICollectionViewCell {
    private var containerView: UIView = {
        let view = UIView()
        view.addCorner(style: .small)
        return view
    }()

    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .normal
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.1
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - UICollectionViewCell Var/Funcs
extension SelectionCollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            let action: Transform = isHighlighted ? .shrink : .inflate
            transform(type: action)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SelectionCollectionViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [containerView])
        containerView.add(subviews: [selectionLabel])
    }

    func setupColors() {
        backgroundColor = .dynamicWhite
        contentView.backgroundColor = .clear
        selectionLabel.backgroundColor = .clear

        if isSelected {
            selectionLabel.textColor = .dynamicWhite
        } else {
            selectionLabel.textColor = .systemBlue
            containerView.backgroundColor = .dimmedDarkGray
        }
    }

    func addConstraints() {
        containerView.autoPinEdges(to: contentView)
        selectionLabel.autoPinEdges(to: containerView)
    }
}

// MARK: - Funcs
extension SelectionCollectionViewCell {
    private func setup() {
        addViews()
        setupColors()
        addConstraints()
    }

    func configure(title: String) {
        selectionLabel.text = title
    }

    // Invert the title color and background color when selection state changes
    func tapped() {
        contentView.layoutIfNeeded()

        UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
            guard let self = self else { return }

            if self.isSelected {
                self.selectionLabel.textColor = .dynamicWhite
                self.containerView.addGradient(colors: [.customBlue, .customLightGray])
            } else {
                self.selectionLabel.textColor = .systemBlue
                self.containerView.backgroundColor = .dimmedDarkGray
                self.containerView.removeGradient()
            }
        }
    }

    private func transform(type: Transform) {
        UIView.animate(withDuration: .defaultAnimationTime,
                       delay: 0,
                       options: [.curveEaseInOut],
                       animations: { [weak self] in
            switch type {
            case .shrink:
                self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            case .inflate:
                self?.transform = CGAffineTransform.identity
            }
        })
    }
}
