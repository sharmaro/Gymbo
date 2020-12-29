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

// MARK: - Funcs
extension VCFactory {
    static func makeCreateEditExerciseTVC(
        exercise: Exercise = Exercise(),
        state: ExerciseState = .create,
        delegate: ExerciseDataModelDelegate? = nil
    ) -> CreateEditExerciseTVC {
        let createEditExerciseTVC = CreateEditExerciseTVC()
        createEditExerciseTVC.exercise = exercise
        createEditExerciseTVC.exerciseState = state
        createEditExerciseTVC.exerciseDataModelDelegate = delegate
        createEditExerciseTVC.customDataSource = CreateEditExerciseTVDS(
            listDataSource: createEditExerciseTVC)
        createEditExerciseTVC.customDelegate = CreateEditExerciseTVD()
        return createEditExerciseTVC
    }

    static func makeCreateEditSessionTVC(session: Session = Session(),
                                         state: SessionState) -> CreateEditSessionTVC {
        let createEditSessionTVC = CreateEditSessionTVC()
        createEditSessionTVC.customDataSource = CreateEditSessionTVDS(
            listDataSource: createEditSessionTVC)
        createEditSessionTVC.customDataSource?.session = session
        createEditSessionTVC.customDataSource?.sessionState = state
        createEditSessionTVC.customDelegate = CreateEditSessionTVD(
            listDelegate: createEditSessionTVC)
        return createEditSessionTVC
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

    static func makeExercisePreviewTVC(exercise: Exercise,
                                       exercisesTVDS: ExercisesTVDS?) -> ExercisePreviewTVC {
        let exercisePreviewTVC = ExercisePreviewTVC(exercisesTVDS: exercisesTVDS)
        exercisePreviewTVC.customDataSource = ExercisePreviewTVDS()
        exercisePreviewTVC.customDataSource?.exercise = exercise
        exercisePreviewTVC.customDelegate = ExercisePreviewTVD()
        exercisePreviewTVC.customDelegate?.exercise = exercise
        return exercisePreviewTVC
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

    static func makeRestVC(isTimerActive: Bool,
                           totalRestTime: Int,
                           restTimeRemaining: Int,
                           delegate: RestTimerDelegate?) -> RestVC {
        let restVC = RestVC()
        restVC.isTimerActive = isTimerActive
        restVC.startSessionTotalRestTime = totalRestTime
        restVC.startSessionRestTimeRemaining = restTimeRemaining
        restVC.restTimerDelegate = delegate
        restVC.customDSAndD = RestDSAndD()
        return restVC
    }

    static func makeSessionPreviewTVC(session: Session,
                                      delegate: SessionProgressDelegate?,
                                      sessionsCVDS: SessionsCVDS?) -> SessionPreviewTVC {
        let sessionPreviewTVC = SessionPreviewTVC()
        sessionPreviewTVC.sessionProgressDelegate = delegate
        sessionPreviewTVC.sessionsCVDS = sessionsCVDS
        sessionPreviewTVC.customDataSource = SessionPreviewTVDS()
        sessionPreviewTVC.customDataSource?.session = session
        sessionPreviewTVC.customDelegate = SessionPreviewTVD()
        return sessionPreviewTVC
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

    static func makeSettingsTVC(style: UITableView.Style) -> SettingsTVC {
        let settingsTVC = SettingsTVC(style: style)
        settingsTVC.customDataSource = SettingsTVDS()
        settingsTVC.customDelegate = SettingsTVD(
            listDelegate: settingsTVC)
        return settingsTVC
    }

    static func makeStopwatchVC() -> StopwatchVC {
        let stopwatchVC = StopwatchVC()
        stopwatchVC.customDataSource = StopwatchTVDS(
            listDataSource: stopwatchVC)
        stopwatchVC.customDelegate = StopwatchTVD()
        return stopwatchVC
    }
}
