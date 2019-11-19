//
//  CustomButton.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/4/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class CustomButton: UIButton {
    override var isHighlighted: Bool {
        didSet {
            if isEnabled {
                alpha = isHighlighted ? 0.3 : 1.0
            }
        }
    }

    var textColor: UIColor = .black {
        didSet {
            setTitleColor(textColor, for: .normal)
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

    var borderWidth: CGFloat = 1.5 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    var borderColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = borderColor.cgColor
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
        setTitleColor(textColor, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel?.lineBreakMode = .byWordWrapping
    }

    func addCornerRadius(_ radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = false
        clipsToBounds = true
    }
}
