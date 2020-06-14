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
    private var selectionLabel = UILabel()

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
}

// MARK: - ViewAdding
extension SelectionCollectionViewCell: ViewAdding {
    func addViews() {
        add(subviews: [selectionLabel])
    }

    func setupViews() {
        selectionLabel.textColor = .systemBlue
        selectionLabel.textAlignment = .center
        selectionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        selectionLabel.font = .normal
        selectionLabel.numberOfLines = 0
        selectionLabel.minimumScaleFactor = 0.1
        selectionLabel.adjustsFontSizeToFitWidth = true
        selectionLabel.addCorner(style: .small)
    }

    func addConstraints() {
        selectionLabel.autoPinEdges(to: self)
    }
}

// MARK: - Funcs
extension SelectionCollectionViewCell {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    private func transform(type: Transform) {
        UIView.animate(withDuration: 0.2,
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

    func configure(title: String) {
        selectionLabel.text = title
    }

    // Invert the title color and background color when selection state changes
    func tapped() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }

            if self.isSelected {
                self.selectionLabel.textColor = .white
                self.selectionLabel.backgroundColor = .systemBlue
            } else {
                self.selectionLabel.textColor = .systemBlue
                self.selectionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            }
        }
    }
}
