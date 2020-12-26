//
//  OnboardingStep.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/25/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

enum OnboardingStep: CaseIterable {
    case exercisesAddButton
    case exercisesTab
    case profileTab
    case sampleSession
    case sessionsAddButton
    case sessionsEditButton
    case sessionsTab
    case stopwatchTab

    private var windowMainTBC: MainTBC? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let mainTBC = appDelegate.window?.rootViewController as? MainTBC else {
            return nil
        }
        return mainTBC
    }

    private var profileVC: ProfileVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?.first as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? ProfileVC
    }

    private var exercisesTVC: ExercisesTVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[1] as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? ExercisesTVC
    }

    private var sessionsCVC: SessionsCVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[2] as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? SessionsCVC
    }

    private var stopwatchVC: StopwatchVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[3] as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? StopwatchVC
    }

    private var imageSize: CGSize {
        CGSize(width: 100, height: 100)
    }

    private var tabBarItemOrigin: CGPoint {
        guard var subviews = windowMainTBC?.tabBar.subviews,
              subviews.count >= 4 else {
            return .zero
        }
        subviews.removeFirst()

        var response = CGPoint.zero
        let index: Int

        switch self {
        case .profileTab:
            index = 0
        case .exercisesTab:
            index = 1
        case .sessionsTab:
            index = 2
        case .stopwatchTab:
            index = 3
        default:
            return .zero
        }

        let view = subviews[index]
        response.x = view.frame.origin.x
        let tabBarHeight = windowMainTBC?.tabBar.frame.height ?? 0
        response.y = UIScreen.main.bounds.height -
                     imageSize.height -
                     tabBarHeight
        return response
    }

    private var addButtonOrigin: CGPoint {
        var outerVC = UIViewController()
        switch self {
        case .exercisesAddButton:
            guard let vc = exercisesTVC else {
                return .zero
            }
            outerVC = vc
        case .sessionsAddButton:
            guard let vc = sessionsCVC else {
                return .zero
            }
            outerVC = vc
        default:
            return .zero
        }

        let x = UIScreen.main.bounds.width - imageSize.width - 44
        let statusBarHeight = outerVC.navigationController?
            .view.window?.windowScene?
            .statusBarManager?.statusBarFrame.height ?? 0
        return CGPoint(x: x,
                       y: statusBarHeight - 28)
    }

    static var defaultOrder: [OnboardingStep] {
        [
            .sampleSession, .sessionsEditButton, .sessionsAddButton,
            .profileTab, .exercisesTab, .exercisesAddButton,
            .sessionsTab, .stopwatchTab
        ]
    }

    private var continueButtonText: String {
        self == .stopwatchTab ? "Done" : "Next"
    }

    private var exercisesTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle = CGFloat(0)
        let textViewText = "This is your Exercises tab. All your exercises are here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    private var exercisesAddButtonData: OnboardingStepData? {
        let imageOrigin = addButtonOrigin
        let transformAngle: CGFloat = -(.pi / 2)
        let textViewText = "Use this to add more exercises. No limits!"
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var profileTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle: CGFloat = .pi / 2
        let textViewText = "This is your Profile tab. You can track useful info here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    private var sampleSessionData: OnboardingStepData? {
        let navigationBarFrame = sessionsCVC?.navigationController?
            .navigationBar.frame ?? .zero
        let cVCellFrame = sessionsCVC?.collectionView.subviews.first?.frame ?? .zero
        let statusBarHeight = sessionsCVC?.navigationController?
            .view.window?.windowScene?
            .statusBarManager?.statusBarFrame.height ?? 0
        let imageOrigin = CGPoint(x: (cVCellFrame.width / 2) -
                                     (imageSize.width / 2) + 5,
                                  y: navigationBarFrame.height +
                                     cVCellFrame.height +
                                     statusBarHeight + 5)
        let transformAngle: CGFloat = .pi / 2
        let textViewText = "This is where all your sessions are."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var sessionsAddButtonData: OnboardingStepData? {
        let imageOrigin = addButtonOrigin
        let transformAngle: CGFloat = .pi
        let textViewText = "Use this to add more sessions. No limits!"
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var sessionsEditButtonData: OnboardingStepData? {
        let statusBarHeight = sessionsCVC?.navigationController?
            .view.window?.windowScene?
            .statusBarManager?.statusBarFrame.height ?? 0
        let imageOrigin = CGPoint(x: 52,
                                  y: statusBarHeight - 28)
        let transformAngle: CGFloat = -(.pi / 2)
        let textViewText = "Use this to edit your sessions."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var sessionsTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle: CGFloat = .pi / 2
        let textViewText = "This is your Sessions tab. Interact with your sessions here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    private var stopwatchTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle = CGFloat(0)
        let textViewText = "This is your Stopwatch tab. Time any important events here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    var data: OnboardingStepData {
        let data: OnboardingStepData?
        switch self {
        case .exercisesAddButton:
            data = exercisesAddButtonData
        case .exercisesTab:
            data = exercisesTabData
        case .profileTab:
            data = profileTabData
        case .sampleSession:
            data = sampleSessionData
        case .sessionsAddButton:
            data = sessionsAddButtonData
        case .sessionsEditButton:
            data = sessionsEditButtonData
        case .sessionsTab:
            data = sessionsTabData
        case .stopwatchTab:
            data = stopwatchTabData
        }

        guard let unwrappedData = data else {
            return OnboardingStepData(imageOrigin: .zero,
                                      transformAngle: 0,
                                      textViewText: "",
                                      continueButtonText: "",
                                      arrowOnTop: true)
        }
        return unwrappedData
    }
}
