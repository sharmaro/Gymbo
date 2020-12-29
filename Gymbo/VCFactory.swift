//
//  VCFactory.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/27/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
struct VCFactory {
    typealias TransitioningDelegate = UIViewControllerTransitioningDelegate
}

// MARK: - Structs/Enums
private extension VCFactory {
}

// MARK: - Funcs
extension VCFactory {
    static func makeCreateEditExerciseTVC(state: ExerciseState = .create) -> CreateEditExerciseTVC {
        let createEditExerciseTVC = CreateEditExerciseTVC()
        createEditExerciseTVC.customDataSource = CreateEditExerciseTVDS(
            listDataSource: createEditExerciseTVC)
        createEditExerciseTVC.customDelegate = CreateEditExerciseTVD(
            listDelegate: createEditExerciseTVC)
        createEditExerciseTVC.exerciseState = state
        return createEditExerciseTVC
    }

    static func makeDashboardCVC(layout: UICollectionViewLayout) -> DashboardCVC {
        let dashboardCVC = DashboardCVC(
            collectionViewLayout: layout)
        dashboardCVC.customDataSource = DashboardCVDS(
            listDataSource: dashboardCVC)
        dashboardCVC.customDelegate = DashboardCVD(
            listDelegate: dashboardCVC)
        return dashboardCVC
    }

    static func makeExercisesTVC(style: UITableView.Style) -> ExercisesTVC {
        let exercisesTVC = ExercisesTVC(style: style)
        exercisesTVC.customDataSource = ExercisesTVDS(
            listDataSource: exercisesTVC)
        exercisesTVC.customDelegate = ExercisesTVD(
            listDelegate: exercisesTVC)
        return exercisesTVC
    }

    static func makeMainNC(rootVC: UIViewController,
                           transitioningDelegate: TransitioningDelegate? = nil) -> MainNC {
        let mainNC = MainNC(rootVC: rootVC)
        if transitioningDelegate != nil {
            mainNC.modalPresentationStyle = .custom
            mainNC.modalTransitionStyle = .crossDissolve
            mainNC.transitioningDelegate = transitioningDelegate
        }
        return mainNC
    }

    static func makeMainTBC() -> MainTBC {
        /**
         Not initializing MainTBC with data source leads to viewDidLoad()
         being called before data source has been assigned.
         */
        let mainTBC = MainTBC(customDataSource: MainTBDS())
        return mainTBC
    }

    static func makeOnboardingVC() -> OnboardingVC {
        let onboardingVC = OnboardingVC()
        onboardingVC.modalPresentationStyle = .overCurrentContext
        onboardingVC.modalTransitionStyle = .crossDissolve
        return onboardingVC
    }

    static func makeProfileTVC() -> ProfileTVC {
        let profileTVC = ProfileTVC()
        profileTVC.customDataSource = ProfileTVDS(
            listDataSource: profileTVC)
        profileTVC.customDelegate = ProfileTVD(
            listDelegate: profileTVC)
        return profileTVC
    }

    static func makeSessionsCVC(layout: UICollectionViewLayout) -> SessionsCVC {
        let sessionsCVC = SessionsCVC(
            collectionViewLayout: layout)
        sessionsCVC.customDataSource = SessionsCVDS(
            listDataSource: sessionsCVC)
        sessionsCVC.customDelegate = SessionsCVD(
            listDelegate: sessionsCVC)
        return sessionsCVC
    }

    static func makeStopwatchVC() -> StopwatchVC {
        let stopwatchVC = StopwatchVC()
        stopwatchVC.customDataSource = StopwatchTVDS(
            listDataSource: stopwatchVC)
        stopwatchVC.customDelegate = StopwatchTVD(
            listDelegate: stopwatchVC)
        return stopwatchVC
    }
}
