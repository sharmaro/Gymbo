//
//  TextViewTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class TextViewTableViewCell: UITableViewCell {
    private let textView: UITextView = {
        let textView = UITextView()
        textView.font = .normal
        textView.addBorder()
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.addCorner(style: .small)
        return textView
    }()

    // Can't override text property
    var textViewText: String? {
        textView.text
    }

    weak var textViewTableViewCellDelegate: TextViewTableViewCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }
}

// MARK: - UITableViewCell Var/Funcs
extension TextViewTableViewCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        textView.text?.removeAll()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension TextViewTableViewCell: ViewAdding {
    func addViews() {
        contentView.add(subviews: [textView])
    }

    func setupViews() {
        selectionStyle = .none

        textView.delegate = self
        let textViewToolBar = UIToolbar()
        textViewToolBar.barStyle = .default
        textViewToolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done",
                            style: .plain,
                            target: self,
                            action: #selector(doneToolbarButtonTapped))
        ]
        textViewToolBar.sizeToFit()
        textView.inputAccessoryView = textViewToolBar
    }

    func setupColors() {
        backgroundColor = .mainWhite
        contentView.backgroundColor = .clear
        textView.textColor = .mainBlack
        textView.layer.borderColor = UIColor.defaultUnselectedBorder.cgColor
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
}

// MARK: - Funcs
extension TextViewTableViewCell {
    private func setup() {
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    func configure(text: String?) {
        if let lastCharacter = text?.last,
            lastCharacter == "\n" {
            textView.text = String(text?.dropLast() ?? "")
        } else {
            textView.text = text
        }
    }

    @objc private func doneToolbarButtonTapped() {
        endEditing(true)
    }
}

// MARK: - UITextViewDelegate
extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewTableViewCellDelegate?.textViewDidBeginEditing(textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        textViewTableViewCellDelegate?.textViewDidChange(textView, cell: self)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textViewTableViewCellDelegate?.textViewDidEndEditing(textView)
    }
}
