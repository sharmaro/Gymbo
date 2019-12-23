//
//  SessionTableHeaderView.swift
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

class SessionTableHeaderView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var infoTextView: UITextView!

    var isContentEditable = true {
        didSet {
            nameTextView.isEditable = isContentEditable
            infoTextView.isEditable = isContentEditable
        }
    }

    var textViews = [UITextView]()

    weak var sessionHeaderTextViewsDelegate: SessionHeaderTextViewsDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        Bundle.main.loadNibNamed(String(describing: SessionTableHeaderView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setupTextViews()
    }

    private func setupTextViews() {
        nameTextView.font = UIFont.systemFont(ofSize: 26, weight: .medium)
        nameTextView.tag = 0

        infoTextView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
}

extension SessionTableHeaderView: UITextViewDelegate {
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
