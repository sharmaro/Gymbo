//
//  OnboardingVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/25/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class OnboardingVC: UIViewController {
    private var arrowImageView: UIImageView = {
        let size = CGSize(width: 100, height: 100)
        let origin = CGPoint(x: -size.width, y: -size.height)
        let imageView = UIImageView(frame: CGRect(origin: origin,
                                                  size: size))
        let image = UIImage(named: "pointer_arrow")?
            .withRenderingMode(.alwaysTemplate)
        imageView.image = image
        imageView.contentMode = .scaleToFill
        imageView.tintColor = .customOrange
        return imageView
    }()

    private var infoTextView: UITextView = {
        let textView = UITextView()
        textView.font = .normal
        textView.textColor = .white
        textView.textAlignment = .center
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.backgroundColor = .black
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.addCorner(style: .small)
        textView.addBorder(color: .darkGray)
        return textView
    }()

    private var continueButton: CustomButton = {
        let button = CustomButton(frame: CGRect(
                                    origin: CGPoint(x: -100,
                                                    y: -45),
                                    size: CGSize(width: 100,
                                                 height: 45)))
        button.title = "Next"
        button.titleLabel?.textAlignment = .center
        button.set(backgroundColor: .systemGreen)
        button.addCorner(style: .small)
        return button
    }()

    private var onboardingStepIndex = -1
    private let onboardingSteps = OnboardingStep.defaultOrder

    private var currentOnboardingStep: OnboardingStep {
        onboardingSteps[onboardingStepIndex]
    }

    private var windowMainTBC: MainTBC? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let mainTBC = appDelegate.window?.rootViewController as? MainTBC else {
            return nil
        }
        return mainTBC
    }
}

// MARK: - UIViewController Var/Funcs
extension OnboardingVC {
    override func viewDidLoad() {
        super.viewDidLoad()

        addViews()
        setupViews()
        setupColors()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let leftButtonAction: (() -> Void)? = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true) {
                    User.firstTimeLoadComplete()
                }
            }
        }

        let rightButtonAction: (() -> Void)? = { [weak self] in
            DispatchQueue.main.async {
                self?.view.backgroundColor = UIColor
                    .dynamicBlack.withAlphaComponent(0.3)
                UIView.animate(withDuration: .defaultAnimationTime) {
                    self?.view.alpha = 1
                } completion: { _ in
                    self?.implementStep()
                }
            }
        }
        presentCustomAlert(alertData: AlertData(title: "Tour",
                                                content: "Hi there! Would you like to take a quick tour?",
                                                leftButtonTitle: "No thanks",
                                                rightButtonTitle: "Sounds good",
                                                leftButtonAction: leftButtonAction,
                                                rightButtonAction: rightButtonAction))
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension OnboardingVC: ViewAdding {
    func addViews() {
        view.addSubview(arrowImageView)
        view.addSubview(infoTextView)
        view.addSubview(continueButton)
    }

    func setupViews() {
        view.backgroundColor = .clear
        view.alpha = 0

        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        view.backgroundColor = view.backgroundColor
        continueButton.set(backgroundColor: .systemGreen)
    }
}

// MARK: - Funcs
extension OnboardingVC {
    private func implementStep() {
        onboardingStepIndex += 1

        if onboardingStepIndex < onboardingSteps.count {
            moveViews(with: currentOnboardingStep.data)
        } else {
            windowMainTBC?.selectedIndex = 2
            User.firstTimeLoadComplete()
            dismiss(animated: true)
        }
    }

    private func moveViews(with stepData: OnboardingStepData) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: .defaultAnimationTime) {
                self?.moveArrowImageView(with: stepData)
                self?.moveInfoTextView(with: stepData)
                self?.moveContinueButton(with: stepData)
            } completion: { _ in
                self?.selectTab()
            }
        }
    }

    private func moveArrowImageView(with stepData: OnboardingStepData) {
        arrowImageView.frame.origin = stepData.imageOrigin
        arrowImageView.transform = arrowImageView
            .transform.rotated(by: stepData.transformAngle)
    }

    private func moveInfoTextView(with stepData: OnboardingStepData) {
        infoTextView.frame.size.width = arrowImageView.frame.width
        infoTextView.text = stepData.textViewText
        infoTextView.sizeToFit()
        let textViewOriginX = stepData.imageOrigin.x
        let textViewOriginY: CGFloat
        if stepData.arrowOnTop {
            textViewOriginY = stepData.imageOrigin.y +
                              arrowImageView.frame.height
        } else {
            textViewOriginY = stepData.imageOrigin.y -
                              infoTextView.frame.height
        }
        infoTextView.frame.origin = CGPoint(x: textViewOriginX,
                                            y: textViewOriginY)
    }

    private func moveContinueButton(with stepData: OnboardingStepData) {
        let continueButtonX = infoTextView.frame.origin.x
        let continueButtonY: CGFloat
        if stepData.arrowOnTop {
            continueButtonY = infoTextView.frame.origin.y +
                              infoTextView.frame.height + 1
        } else {
            continueButtonY = infoTextView.frame.origin.y -
                              continueButton.frame.height - 1
        }
        continueButton.frame.origin = CGPoint(x: continueButtonX,
                                              y: continueButtonY)
        continueButton.frame.size.width = arrowImageView.frame.width
        let buttonTitle = stepData.continueButtonText
        continueButton.setTitle(buttonTitle, for: .normal)
    }

    private func selectTab() {
        let index: Int
        switch currentOnboardingStep {
        case .profileTab:
            index = 0
        case .exercisesTab:
            index = 1
        case .sessionsTab:
            index = 2
        case .stopwatchTab:
            index = 3
        default:
            return
        }
        windowMainTBC?.selectedIndex = index
    }

    @objc private func continueButtonTapped(_ sender: Any) {
        Haptic.sendSelectionFeedback()
        implementStep()
    }
}
