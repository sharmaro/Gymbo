//
//  ToggleButton.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/14/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ToggleButton: CustomButton {
    private var itemIndex = 0

    var items: [String]

    init(items: [String], frame: CGRect = .zero) {
        self.items = items

        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        items = []

        super.init(coder: aDecoder)
        setup()
    }
}

// MARK: - Funcs
extension ToggleButton {
    func setCurrentItem(item: String?) {
        guard let item = item,
            let firstIndex = items.firstIndex(of: item) else {
            return
        }

        title = item
        itemIndex = firstIndex
    }

    private func setup() {
        title = items.first ?? ""
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped(_ sender: Any) {
        itemIndex += 1
        if itemIndex >= items.count {
            itemIndex = 0
        }

        UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
            self?.title = self?.items[self?.itemIndex ?? 0] ?? ""
        }
    }
}
