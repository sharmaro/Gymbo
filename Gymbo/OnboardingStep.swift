//
//  OnboardingStep.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/25/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

enum OnboardingStep: CaseIterable {
    case profileTab
    case profileSettingsButton
    case dashboardTab
    case sessionsTab
    case sampleSession
    case sessionsEditButton
    case sessionsAddButton
    case exercisesTab
    case exercisesAddButton
    case stopwatchTab

    private var windowMainTBC: MainTBC? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let mainTBC = appDelegate.window?.rootViewController as? MainTBC else {
            return nil
        }
        return mainTBC
    }

    private var profileTVC: ProfileTVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?.first as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? ProfileTVC
    }

    private var dashboardCVC: DashboardCVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[1] as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? DashboardCVC
    }

    private var sessionsCVC: SessionsCVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[2] as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? SessionsCVC
    }

    private var exercisesVC: ExercisesVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[3] as? MainNC else {
            return nil
        }
        return mainNC.viewControllers.first as? ExercisesVC
    }

    private var stopwatchVC: StopwatchVC? {
        guard let mainNC = windowMainTBC?
                .viewControllers?[4] as? MainNC else {
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
        case .dashboardTab:
            index = 1
        case .sessionsTab:
            index = 2
        case .exercisesTab:
            index = 3
        case .stopwatchTab:
            index = 4
        default:
            return .zero
        }

        let view = subviews[index]
        response.x = view.frame.origin.x
        let tabBarHeight = windowMainTBC?.tabBar.frame.height ?? 0
        response.y = UIScreen.main.bounds.height -
                     imageSize.height -
                     tabBarHeight
        if index == 4 {
            response.x -= 25
        }
        return response
    }

    private var rightNavBarButtonOrigin: CGPoint {
        var outerVC = UIViewController()
        switch self {
        case .exercisesAddButton:
            guard let vc = exercisesVC else {
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

    private var leftNavBarButtonOrigin: CGPoint {
        var outerVC = UIViewController()
        switch self {
        case .profileSettingsButton:
            guard let vc = profileTVC else {
                return .zero
            }
            outerVC = vc
        case .sessionsEditButton:
            guard let vc = sessionsCVC else {
                return .zero
            }
            outerVC = vc
        default:
            return .zero
        }

        let statusBarHeight = outerVC.navigationController?
            .view.window?.windowScene?
            .statusBarManager?.statusBarFrame.height ?? 0
        return CGPoint(x: 52, y: statusBarHeight - 28)
    }

    private var continueButtonText: String {
        self == .stopwatchTab ? "Done" : "Next"
    }

    private var profileTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle: CGFloat = -(.pi / 2)
        let textViewText = "This is your Profile tab. You can track useful info here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    private var profileSettingsButtonData: OnboardingStepData? {
        let imageOrigin = leftNavBarButtonOrigin
        let transformAngle: CGFloat = .pi / 2
        let textViewText = "Use this to manage your settings."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var dashboardTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle: CGFloat = -(.pi / 2)
        let textViewText = "This is your Dashboard tab. Your past sessions history is here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    private var sessionsTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let textViewText = "This is your Sessions tab. Interact with your sessions here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: 0,
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
        let transformAngle: CGFloat = .pi
        let textViewText = "This is what a sample session looks like."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var sessionsEditButtonData: OnboardingStepData? {
        let imageOrigin = leftNavBarButtonOrigin
        let transformAngle: CGFloat = -(.pi / 2)
        let textViewText = "Use this to edit your sessions."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var sessionsAddButtonData: OnboardingStepData? {
        let imageOrigin = rightNavBarButtonOrigin
        let transformAngle: CGFloat = .pi
        let textViewText = "Use this to add more sessions. No limits!"
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var exercisesTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle: CGFloat = .pi / 2
        let textViewText = "This is your Exercises tab. All your exercises are here."
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: false)
    }

    private var exercisesAddButtonData: OnboardingStepData? {
        let imageOrigin = rightNavBarButtonOrigin
        let transformAngle: CGFloat = -(.pi / 2)
        let textViewText = "Use this to add more exercises. No limits!"
        return OnboardingStepData(imageOrigin: imageOrigin,
                                  transformAngle: transformAngle,
                                  textViewText: textViewText,
                                  continueButtonText: continueButtonText,
                                  arrowOnTop: true)
    }

    private var stopwatchTabData: OnboardingStepData? {
        let imageOrigin = tabBarItemOrigin
        let transformAngle: CGFloat  = .pi / 2
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
        case .profileTab:
            data = profileTabData
        case .profileSettingsButton:
            data = profileSettingsButtonData
        case .dashboardTab:
            data = dashboardTabData
        case .sessionsTab:
            data = sessionsTabData
        case .sampleSession:
            data = sampleSessionData
        case .sessionsEditButton:
            data = sessionsEditButtonData
        case .sessionsAddButton:
            data = sessionsAddButtonData
        case .exercisesTab:
            data = exercisesTabData
        case .exercisesAddButton:
            data = exercisesAddButtonData
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
