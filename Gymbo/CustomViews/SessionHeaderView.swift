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

class SessionHeaderView: UIView {
    // MARK: - Properties
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var nameTextView: UITextView!
    @IBOutlet private weak var infoTextView: UITextView!

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

        static let nameTextViewFontSize = CGFloat(28)
        static let infoTextViewFontSize = CGFloat(20)
    }
}

// MARK: - Funcs
extension SessionHeaderView {
    private func setup() {
        Bundle.main.loadNibNamed(String(describing: SessionHeaderView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setupTextViews()
    }

    private func setupTextViews() {
        nameTextView.font = UIFont.systemFont(ofSize: Constants.nameTextViewFontSize, weight: .medium)
        nameTextView.tag = 0

        infoTextView.font = UIFont.systemFont(ofSize: Constants.infoTextViewFontSize, weight: .regular)
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
        nameTextView.becomeFirstResponder()
    }

    func configure(dataModel: SessionHeaderViewModel) {
        nameTextView.text = dataModel.name
        infoTextView.text = dataModel.info
        nameTextView.textColor = dataModel.textColor
        infoTextView.textColor = dataModel.textColor
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
