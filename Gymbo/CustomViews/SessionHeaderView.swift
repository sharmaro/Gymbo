//
//  SessionHeaderView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/21/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol SessionHeaderTextViewsDelegate: class {
    func textViewDidBeginEditing(_ textView: UITextView)
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func textViewDidEndEditing(_ textView: UITextView)
}

struct SessionHeaderViewModel {
    var name: String?
    var info: String?
    var textColor = UIColor.black
}

// MARK: - Properties
class SessionHeaderView: UIView {
    private var nameTextView = UITextView(frame: .zero)
    private var infoTextView = UITextView(frame: .zero)

    var sessionName: String? {
        return nameTextView.text
    }

    var info: String {
        return infoTextView.text
    }

    var shouldSaveName: Bool {
        return nameTextView.textColor != Constants.dimmedBlack && nameTextView.text.count > 0
    }

    var isContentEditable = true {
        didSet {
            nameTextView.isEditable = isContentEditable
            infoTextView.isEditable = isContentEditable
        }
    }

    private var textViews = [UITextView]()

    weak var sessionHeaderTextViewsDelegate: SessionHeaderTextViewsDelegate?

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

// MARK: - Structs/Enums
private extension SessionHeaderView {
    struct Constants {
        static let dimmedBlack = UIColor.black.withAlphaComponent(0.2)
    }
}

// MARK: - ViewAdding
extension SessionHeaderView: ViewAdding {
    func addViews() {
        add(subviews: [nameTextView, infoTextView])
    }

    func setupViews() {
        nameTextView.font = UIFont.xLarge.medium
        nameTextView.tag = 0

        infoTextView.font = UIFont.medium.medium
        infoTextView.tag = 1

        textViews = [nameTextView, infoTextView]
        for textView in textViews {
            textView.isSelectable = false
            textView.isScrollEnabled = false
            textView.isEditable = true
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
            textView.textContainer.lineBreakMode = .byWordWrapping
            textView.returnKeyType = .done
            textView.autocorrectionType = .no
            textView.delegate = self
        }
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            nameTextView.topAnchor.constraint(equalTo: topAnchor),
            nameTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            nameTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            nameTextView.bottomAnchor.constraint(equalTo: infoTextView.topAnchor),
            nameTextView.heightAnchor.constraint(equalToConstant: 32)
        ])

        NSLayoutConstraint.activate([
            infoTextView.leadingAnchor.constraint(equalTo: leadingAnchor),
            infoTextView.trailingAnchor.constraint(equalTo: trailingAnchor),
            infoTextView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Funcs
extension SessionHeaderView {
    private func setup() {
        addViews()
        setupViews()
        addConstraints()
    }

    func configure(dataModel: SessionHeaderViewModel) {
        nameTextView.text = dataModel.name
        infoTextView.text = dataModel.info
        nameTextView.textColor = dataModel.textColor
        infoTextView.textColor = dataModel.textColor
    }

    func makeFirstResponder() {
        nameTextView.becomeFirstResponder()
    }
}

// MARK: - UITextViewDelegate
extension SessionHeaderView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        sessionHeaderTextViewsDelegate?.textViewDidBeginEditing(textViews[textView.tag])
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return sessionHeaderTextViewsDelegate?.textView(textViews[textView.tag], shouldChangeTextIn: range, replacementText: text) ?? false
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        sessionHeaderTextViewsDelegate?.textViewDidEndEditing(textViews[textView.tag])
    }
}
