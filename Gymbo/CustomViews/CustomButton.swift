//
//  CustomButton.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class CustomButton: UIButton {
    var title = "" {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    var titleColor = UIColor.mainBlack {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override var isHighlighted: Bool {
        didSet {
            guard isEnabled else {
                return
            }
            alpha = isHighlighted ? Constants.dimmedAlpha : Constants.normalAlpha
            transform(condition: Transform.caseFromBool(bool: isHighlighted))
        }
    }
}

// MARK: - Structs/Enums
private extension CustomButton {
    struct Constants {
        static let dimmedAlpha = CGFloat(0.4)
        static let normalAlpha = CGFloat(1)
        static let transformScale = CGFloat(0.95)
    }
}

// MARK: - UIButton Var/Funcs
extension CustomButton {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - Funcs
extension CustomButton {
    private func setup() {
        setupColors()
        titleLabel?.lineBreakMode = .byWordWrapping
    }

    private func setupColors() {
        backgroundColor = backgroundColor
        setTitleColor(titleColor, for: .normal)
    }

    private func transform(condition: Transform) {
        UIView.animate(withDuration: .defaultAnimationTime,
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

    func add(backgroundColor: UIColor, titleColor: UIColor = .mainWhite) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
    }

    func makeUninteractable(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
                self?.alpha = Constants.dimmedAlpha
            }
        } else {
            alpha = Constants.dimmedAlpha
        }
        isEnabled = false
    }

    func makeInteractable(animated: Bool = true) {
        if animated {
            UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
                self?.alpha = Constants.normalAlpha
            }
        } else {
            alpha = Constants.normalAlpha
        }
        isEnabled = true
    }
}
