//
//  SessionHeaderView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/21/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionHeaderView: UIView {
    private let firstTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.xLarge.medium
        textView.returnKeyType = .next
        textView.tag = 0
        return textView
    }()

    private let secondTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.medium.medium
        textView.tag = 1
        return textView
    }()

    var firstText: String? {
        firstTextView.text
    }

    var secondText: String {
        secondTextView.text
    }

    var isFirstTextValid: Bool {
        firstTextView.textColor != .dimmedDarkGray && !firstTextView.text.isEmpty
    }

    var isContentEditable = true {
        didSet {
            firstTextView.isEditable = isContentEditable
            secondTextView.isEditable = isContentEditable
        }
    }

    private var textViews = [UITextView]()

    weak var customTextViewDelegate: CustomTextViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - UIView Var/Funcs
extension SessionHeaderView {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionHeaderView: ViewAdding {
    func addViews() {
        add(subviews: [firstTextView, secondTextView])
    }

    func setupViews() {
        textViews = [firstTextView, secondTextView]
        for textView in textViews {
            textView.isSelectable = false
            textView.isScrollEnabled = false
            textView.isEditable = true
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.autocorrectionType = .no
            textView.delegate = self
        }
    }

    func setupColors() {
        backgroundColor = .clear
        [firstTextView, secondTextView].forEach {
            $0.backgroundColor = .clear
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            firstTextView.topAnchor.constraint(equalTo: topAnchor),
            firstTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            firstTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            firstTextView.bottomAnchor.constraint(equalTo: secondTextView.topAnchor),

            secondTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            secondTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            secondTextView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ])
    }
}

// MARK: - Funcs
extension SessionHeaderView {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(dataModel: SessionHeaderViewModel) {
        firstTextView.text = dataModel.firstText
        secondTextView.text = dataModel.secondText
        firstTextView.textColor = dataModel.textColor
        secondTextView.textColor = dataModel.textColor
    }

    func makeFirstResponder() {
        firstTextView.becomeFirstResponder()
    }
}

// MARK: - UITextViewDelegate
extension SessionHeaderView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        customTextViewDelegate?.textViewDidChange(textView)
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        customTextViewDelegate?.textViewDidBeginEditing(textViews[textView.tag])
    }

    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        guard text == "\n" else {
            return true
        }

        switch textView.tag {
        case 0:
            textView.resignFirstResponder()
            secondTextView.becomeFirstResponder()
            return false
        case 1:
            break
        default:
            break
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        customTextViewDelegate?.textViewDidEndEditing(textViews[textView.tag])
    }
}
