//
//  TextViewTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol TextViewTableViewCellDelegate: class {
    func textViewDidChange(_ textView: UITextView, cell: TextViewTableViewCell)
}

// MARK: - Properties
class TextViewTableViewCell: UITableViewCell {
    private var textView = UITextView()

    var textViewText: String? {
        return textView.text
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

// MARK: - ReuseIdentifying
extension TextViewTableViewCell: ReuseIdentifying {}

// MARK: - ViewAdding
extension TextViewTableViewCell: ViewAdding {
    func addViews() {
        add(subviews: [textView])
    }

    func setupViews() {
        selectionStyle = .none

        textView.font = .normal
        textView.returnKeyType = .done
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        textView.isScrollEnabled = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.addCorner(style: .small)
        textView.delegate = self
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
}

// MARK: - Funcs
extension TextViewTableViewCell {
    private func setup() {
        addViews()
        setupViews()
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
}

// MARK: - UITextViewDelegate
extension TextViewTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewTableViewCellDelegate?.textViewDidChange(textView, cell: self)
    }
}
