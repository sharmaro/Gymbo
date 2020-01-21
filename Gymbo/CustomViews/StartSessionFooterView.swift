//
//  StartSessionFooterView.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/12/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol StartSessionButtonDelegate: class {
    func addExercise()
    func dismiss()
}

class StartSessionFooterView: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var addExerciseButton: CustomButton!
    @IBOutlet private weak var cancelButton: CustomButton!

    weak var startSessionButtonDelegate: StartSessionButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        Bundle.main.loadNibNamed(String(describing: StartSessionFooterView.self), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setupButtons()
    }

    private func setupButtons() {
        addExerciseButton.title = "+ Exercise"
        addExerciseButton.add(backgroundColor: .systemBlue)
        addExerciseButton.addCornerRadius()

        cancelButton.title = "Cancel"
        cancelButton.add(backgroundColor: .systemRed)
        cancelButton.addCornerRadius()
    }

    @IBAction func addExerciseButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.addExercise()
    }

    @IBAction func cancelButtonTapped(_ sender: Any) {
        startSessionButtonDelegate?.dismiss()
    }
}
