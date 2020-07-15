//
//  ToggleableButton.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ToggleButton: CustomButton {
    private var items = [String]()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(items: [String]) {
        super.init(frame: .zero)
    }
}

// MARK: - Structs/Enums
private extension ToggleButton {
    struct Constants {
    }
}

// MARK: - Funcs
extension ToggleButton {
}
