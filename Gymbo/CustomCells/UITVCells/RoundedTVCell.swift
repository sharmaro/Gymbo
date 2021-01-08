//
//  RoundedTVCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/7/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class RoundedTVCell: UITableViewCell {
    var roundedView = UIView()

    var rightImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .secondaryText
        imageView.isHidden = true
        return imageView
    }()

    private var bottomDivider = UIView()

    var cellLocation = CellLocation.first {
        didSet {
            configureBasedOnLocation()
        }
    }

    var showsRightImage = false {
        didSet {
            updateRightImageViewConstraints()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - UIView Var/Funcs
extension RoundedTVCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        roundedView.backgroundColor = selected ? .selectedBackground : .secondaryBackground
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        roundedView.backgroundColor = highlighted ? .selectedBackground : .secondaryBackground
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension RoundedTVCell {
    private func addViews() {
        contentView.add(subviews: [roundedView])
        roundedView.add(subviews: [rightImageView, bottomDivider])
    }

    private func setupViews() {
        selectionStyle = .none
        roundedView.layer.masksToBounds = true
    }

    private func setupColors() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        roundedView.backgroundColor = .secondaryBackground
        bottomDivider.backgroundColor = .selectedBackground
    }

    private func addConstraints() {
        NSLayoutConstraint.activate([
            roundedView.topAnchor.constraint(equalTo: contentView.topAnchor),
            roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                                                 constant: 20),
            roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,
                                                  constant: -20),
            roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            bottomDivider.leadingAnchor.constraint(equalTo: roundedView.leadingAnchor,
                                                   constant: 20),
            bottomDivider.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor),
            bottomDivider.bottomAnchor.constraint(equalTo: roundedView.bottomAnchor),
            bottomDivider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

// MARK: - Funcs
extension RoundedTVCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    private func updateRightImageViewConstraints() {
        if showsRightImage {
            NSLayoutConstraint.activate([
                rightImageView.centerYAnchor.constraint(equalTo: roundedView.centerYAnchor),
                rightImageView.trailingAnchor.constraint(equalTo: roundedView.trailingAnchor, constant: -10),
                rightImageView.widthAnchor.constraint(equalToConstant: 15),
                rightImageView.heightAnchor.constraint(equalTo: rightImageView.widthAnchor)
            ])
        } else {
            rightImageView.constraints.forEach {
                rightImageView.removeConstraint($0)
            }
        }
        rightImageView.isHidden = !showsRightImage
    }

    private func configureBasedOnLocation() {
        let style = CornerStyle.small
        switch cellLocation {
        case .first:
            roundedView.layer.roundTopCorners(style: style)
            bottomDivider.isHidden = false
        case .middle:
            roundedView.layer.removeCorners()
            bottomDivider.isHidden = false
        case .last:
            roundedView.layer.roundBottomCorners(style: style)
            bottomDivider.isHidden = true
        case .solo:
            roundedView.layer.addCorner(style: style)
            bottomDivider.isHidden = true
        }
    }
}
