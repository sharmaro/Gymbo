//
//  CustomButton.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    // MARK: - Properties
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
        static let dimmedAlpha = CGFloat(0.3)
        static let normalAlpha = CGFloat(1)
    }
}

// MARK: - Funcs
extension CustomButton {
    private func setup() {
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel?.lineBreakMode = .byWordWrapping

        addTarget(self, action: #selector(shrink), for: [.touchDown, .touchDragEnter, .touchDragInside])
        addTarget(self, action: #selector(inflate), for: [.touchUpInside, .touchUpOutside, .touchDragExit, .touchCancel])
    }

    @objc private func shrink() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }

    @objc private func inflate() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.transform = CGAffineTransform.identity
        }
    }

    func addCornerRadius(_ radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? cornerRadius
        layer.masksToBounds = false
        clipsToBounds = true
    }

    func add(backgroundColor: UIColor, textColor: UIColor = .white) {
        self.backgroundColor = backgroundColor
        self.titleColor = textColor
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
