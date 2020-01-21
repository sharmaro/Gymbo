//
//  CustomButton.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    private struct Constants {
        static let dimmedAlpha = CGFloat(0.3)
        static let normalAlpha = CGFloat(1)
    }

    override var isHighlighted: Bool {
        didSet {
            if isEnabled {
                alpha = isHighlighted ? Constants.dimmedAlpha : Constants.normalAlpha
            }
        }
    }

    var title: String = "" {
        didSet {
            setTitle(title, for: .normal)
        }
    }

    var titleColor: UIColor = .black {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }

    var titleFontSize: CGFloat = 15 {
        didSet {
            titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        }
    }

    var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
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

    private func setup() {
        setTitleColor(titleColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel?.lineBreakMode = .byWordWrapping
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

    func makeUninteractable() {
        isEnabled = false
        alpha = Constants.dimmedAlpha
    }

    func makeInteractable() {
        isEnabled = true
        alpha = Constants.normalAlpha
    }
}
