//
//  LargeTitleLabel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class LargeTitleLabel: UILabel {
    // MARK: - UIView Var/Funcs
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - Funcs
extension LargeTitleLabel {
    private func setup() {
        font = UIFont.large.bold
        numberOfLines = 0
        minimumScaleFactor = 0.1
        adjustsFontSizeToFitWidth = true
        sizeToFit()
    }
}
