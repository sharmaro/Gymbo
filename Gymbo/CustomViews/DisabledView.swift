//
//  DisabledView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class DisabledView: UIView {
    private var animator = UIViewPropertyAnimator()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - ViewAdding
extension DisabledView: ViewAdding {
    func setupColors() {
        backgroundColor = .clear
        isHidden = true
        alpha = 0
    }
}

// MARK: - Funcs
extension DisabledView {
    private func setup() {
        setupColors()
    }

    func set(state: InteractionState, animated: Bool = true) {
        animator.stopAnimation(true)

        switch state {
        case .enabled:
            enable(animated: animated)
        case .disabled:
            disable(animated: animated)
        }
    }

    private func enable(animated: Bool = true) {
        if animated {
            animator = UIViewPropertyAnimator(duration: .defaultAnimationTime,
                                              curve: .easeInOut, animations: { [weak self] in
                self?.alpha = 0
            })
            animator.addCompletion { [weak self] _ in
                self?.isHidden = true
            }
            animator.startAnimation()
        } else {
            alpha = 0
            isHidden = true
            backgroundColor = .clear
        }
    }

    private func disable(animated: Bool = true) {
        alpha = 0
        isHidden = false
        backgroundColor = .disabledBlack

        if animated {
            animator = UIViewPropertyAnimator(duration: .defaultAnimationTime,
                                              curve: .easeInOut, animations: { [weak self] in
                self?.alpha = 1
            })
            animator.startAnimation()
        } else {
            alpha = 1
        }
    }
}
