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

    var titleColor = UIColor.primaryText {
        didSet {
            setTitleColor(titleColor, for: .normal)
        }
    }

    private var interactionState = InteractionState.enabled
    private let disabledView = DisabledView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not using storyboards")
    }

    override var isHighlighted: Bool {
        didSet {
            guard isEnabled else {
                return
            }
            Transform.caseFromBool(bool: isHighlighted).transform(view: self)
        }
    }
}

// MARK: - Structs/Enums
private extension CustomButton {
    struct Constants {
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

    private func addDisabledView() {
        add(subviews: [disabledView])
        disabledView.autoPinEdges(to: self)
    }

    func set(backgroundColor: UIColor,
             titleColor: UIColor = .white,
             animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: .defaultAnimationTime) { [weak self] in
                self?.backgroundColor = backgroundColor
                self?.titleColor = titleColor
            }
        } else {
            self.backgroundColor = backgroundColor
            self.titleColor = titleColor
        }
    }

    func set(state: InteractionState, animated: Bool = true) {
        guard interactionState != state else {
            return
        }

        if let lastSubview = subviews.last,
           lastSubview != disabledView {
            addDisabledView()
        }

        isEnabled = state == .enabled
        interactionState = state
        disabledView.set(state: state, animated: animated)
    }
}
