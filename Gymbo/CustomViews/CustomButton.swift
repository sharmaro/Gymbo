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

    var titleColor = UIColor.black {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }

    var titleFontSize: CGFloat = 18 {
        didSet {
            titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        }
    }

    var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }


    // MARK: - UIButton Var/Funcs
    override var isHighlighted: Bool {
        didSet {
            if isEnabled {
                alpha = isHighlighted ? Constants.dimmedAlpha : Constants.normalAlpha
            }
            transform(condition: Transform.caseFromBool(bool: isHighlighted))
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
}

// MARK: - Structs/Enums
private extension CustomButton {
    struct Constants {
        static let dimmedAlpha = CGFloat(0.4)
        static let normalAlpha = CGFloat(1)
        static let transformScale = CGFloat(0.95)

        static let animationTime = TimeInterval(0.2)
    }

    enum Transform {
        case shrink
        case inflate

        static func caseFromBool(bool: Bool) -> Transform {
            return bool ? .shrink : .inflate
        }
    }
}

// MARK: - Funcs
extension CustomButton {
    private func setup() {
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel?.lineBreakMode = .byWordWrapping
    }

    private func transform(condition: Transform) {
        UIView.animate(withDuration: Constants.animationTime,
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

    func addCorner(radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? cornerRadius
        layer.masksToBounds = false
        clipsToBounds = true
    }

    func add(backgroundColor: UIColor, titleColor: UIColor = .white) {
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
    }

    func makeUninteractable(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = Constants.dimmedAlpha
            }
        } else {
            alpha = Constants.dimmedAlpha
        }
        isEnabled = false
    }

    func makeInteractable(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = Constants.normalAlpha
            }
        } else {
            alpha = Constants.normalAlpha
        }
        isEnabled = true
    }
}
