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
        view.backgroundColor = Constants.dimmedBlack
        view.addCorner(style: .small)
        return view
    }()

    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemBlue
        label.textAlignment = .center
        label.backgroundColor = .clear
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
}

// MARK: - Structs/Enums
private extension SelectionCollectionViewCell {
    struct Constants {
        static let dimmedBlack = UIColor.black.withAlphaComponent(0.1)
    }
}

// MARK: - ViewAdding
extension SelectionCollectionViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [containerView])
        containerView.add(subviews: [selectionLabel])
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
        addConstraints()
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

    func configure(title: String) {
        selectionLabel.text = title
    }

    // Invert the title color and background color when selection state changes
    func tapped() {
        contentView.layoutIfNeeded()

        UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
            guard let self = self else { return }

            if self.isSelected {
                self.selectionLabel.textColor = .white
                self.containerView.addGradient(colors: [Color.blue, Color.lightGray])
            } else {
                self.selectionLabel.textColor = .systemBlue
                self.containerView.backgroundColor = Constants.dimmedBlack
                self.containerView.layer.sublayers?.removeFirst()
            }
        }
    }
}
