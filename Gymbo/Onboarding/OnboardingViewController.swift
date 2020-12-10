//
//  OnboardingViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/23/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class OnboardingViewController: UIViewController {
    private let titleLabel: UILabel = {
         let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.font = .xLarge
        return label
    }()

    private var onboardingPage: OnboardingPage

    private var imageViewTopConstraint: NSLayoutConstraint?
    private var infoLabelBottomConstraint: NSLayoutConstraint?

    init(_ onboardingPage: OnboardingPage) {
        self.onboardingPage = onboardingPage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
extension OnboardingViewController {
    private struct Constants {
        static var titleLabelHeight = CGFloat(41)
    }
}

// MARK: - UIViewController Var/Funcs
extension OnboardingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard onboardingPage != .welcome,
            onboardingPage != .finish else {
            return
        }

        imageView.alpha = 0
        infoLabel.alpha = 0

        imageViewTopConstraint?.constant = view.frame.height
        infoLabelBottomConstraint?.isActive = false
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard onboardingPage != .welcome,
            onboardingPage != .finish else {
            return
        }

        imageViewTopConstraint?.constant = 20
        infoLabelBottomConstraint?.isActive = true

        UIView.animate(withDuration: 0.4) {
            self.imageView.alpha = 1
            self.infoLabel.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension OnboardingViewController: ViewAdding {
    func addViews() {
        view.add(subviews: [titleLabel, imageView, infoLabel])
    }

    func setupViews() {
        titleLabel.text = onboardingPage.rawValue
        imageView.image = onboardingPage.image
        infoLabel.text = onboardingPage.info
    }

    func setupColors() {
        view.backgroundColor = .dynamicWhite
        titleLabel.textColor = .dynamicBlack
        infoLabel.textColor = .dynamicDarkGray
    }

    //swiftlint:disable:next function_body_length
    func addConstraints() {
        if onboardingPage == .welcome || onboardingPage == .finish {
            titleLabel.textAlignment = .center
            NSLayoutConstraint.activate([
                titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
                titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight),

                infoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
                infoLabel.safeAreaLayoutGuide.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20),
                infoLabel.safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20),
                infoLabel.heightAnchor.constraint(equalToConstant: 100)
            ])
        } else {
            imageViewTopConstraint = imageView.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: view.frame.height)
            imageViewTopConstraint?.isActive = true

            infoLabelBottomConstraint =
                infoLabel.safeAreaLayoutGuide.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                    constant: -40)

            NSLayoutConstraint.activate([
                titleLabel.safeAreaLayoutGuide.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 20),
                titleLabel.safeAreaLayoutGuide.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20),
                titleLabel.safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20),
                titleLabel.heightAnchor.constraint(equalToConstant: Constants.titleLabelHeight),

                imageView.safeAreaLayoutGuide.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20),
                imageView.safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20),
                imageView.bottomAnchor.constraint(equalTo: infoLabel.topAnchor, constant: -20),

                infoLabel.safeAreaLayoutGuide.leadingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                    constant: 20),
                infoLabel.safeAreaLayoutGuide.trailingAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                    constant: -20),
                infoLabel.heightAnchor.constraint(equalToConstant: 100)
            ])
        }
    }
}
