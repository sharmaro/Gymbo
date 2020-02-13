//
//  SearchTextField.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/11/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol SearchTextFieldDelegate: class {
    func textFieldDidChange(_ textField: UITextField)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
}

class SearchTextField: UITextField {
    // MARK: - Properties
    weak var searchTextFieldDelegate: SearchTextFieldDelegate?

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

// MARK: - Funcs
extension SearchTextField {
    private func setup() {
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        borderStyle = .none
        leftViewMode = .always
        returnKeyType = .done
        delegate = self
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        let searchImageContainerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 28, height: 16)))
        let searchImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: 16, height: 16)))
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.image = UIImage(named: "search")
        searchImageContainerView.addSubview(searchImageView)
        leftView = searchImageContainerView
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        searchTextFieldDelegate?.textFieldDidChange(textField)
    }
}

// MARK: - UITextFieldDelegate
extension SearchTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return searchTextFieldDelegate?.textFieldShouldReturn(textField) ?? true
    }
}
