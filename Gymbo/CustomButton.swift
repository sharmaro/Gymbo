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
            if shouldHighlight {
                alpha = isHighlighted ? 0.5 : 1.0
            }
        }
    }
    
    var shouldHighlight: Bool = true
    
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
        setTitleColor(.black, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: titleFontSize)
        titleLabel?.lineBreakMode = .byWordWrapping
    }
    
    func makeRound(_ radius: CGFloat? = nil) {
        layer.cornerRadius = radius ?? cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = false
        clipsToBounds = true
    }
}
