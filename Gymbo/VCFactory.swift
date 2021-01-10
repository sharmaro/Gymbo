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
    static func makeAllSessionsCVC(
        layout: UICollectionViewLayout = UICollectionViewFlowLayout(),
        user: User?) -> AllSessionsCVC {
        let allSessionsCVC = AllSessionsCVC(collectionViewLayout: layout)
        allSessionsCVC.customDataSource = AllSessionsCVDS(
            listDataSource: allSessionsCVC, user: user)
        allSessionsCVC.customDelegate = AllSessionsCVD(listDelegate: allSessionsCVC)
        return allSessionsCVC
    }

    static func makeAllSessionDaysCVC(
        layout: UICollectionViewLayout = UICollectionViewFlowLayout(),
        user: User?,
        date: Date
    ) -> AllSessionDaysCVC {
        let allSessionDaysCVC = AllSessionDaysCVC(
            collectionViewLayout: layout)
        allSessionDaysCVC.customDataSource = AllSessionDaysCVDS(
            listDataSource: allSessionDaysCVC,
            user: user,
            date: date)
        allSessionDaysCVC.customDelegate = AllSessionDaysCVD(
            listDelegate: allSessionDaysCVC)
        return allSessionDaysCVC
    }

    static func makeAllSessionsDetailTVC(
        session: Session?) -> AllSessionsDetailTVC {
        let allSessionsDetailTVC = AllSessionsDetailTVC(style: .grouped)
        allSessionsDetailTVC.customDataSource = AllSessionsDetailTVDS(
            listDataSource: allSessionsDetailTVC, session: session)
        allSessionsDetailTVC.customDelegate = AllSessionsDetailTVD(
            listDelegate: allSessionsDetailTVC, session: session)
        return allSessionsDetailTVC
    }

    static func makeCreateEditExerciseVC(
        exercise: Exercise = Exercise(),
        state: ExerciseState = .create,
        delegate: ExerciseDataModelDelegate? = nil
    ) -> CreateEditExerciseVC {
        let createEditExerciseVC = CreateEditExerciseVC()
        createEditExerciseVC.exercise = exercise
        createEditExerciseVC.exerciseState = state
        createEditExerciseVC.exerciseDataModelDelegate = delegate
        createEditExerciseVC.customDataSource = CreateEditExerciseTVDS(
            listDataSource: createEditExerciseVC)
        createEditExerciseVC.customDelegate = CreateEditExerciseTVD()
        return createEditExerciseVC
    }

    static func makeCreateEditSessionTVC(user: User?,
                                         session: Session = Session(),
                                         state: SessionState,
                                         exercisesTVDS: ExercisesTVDS?
    ) -> CreateEditSessionTVC {
        let createEditSessionTVC = CreateEditSessionTVC()
        createEditSessionTVC.exercisesTVDS = exercisesTVDS
        createEditSessionTVC.customDataSource = CreateEditSessionTVDS(
            listDataSource: createEditSessionTVC, user: user)
        createEditSessionTVC.customDataSource?.session = session
        createEditSessionTVC.customDataSource?.sessionState = state
        createEditSessionTVC.customDelegate = CreateEditSessionTVD(
            listDelegate: createEditSessionTVC)
        return createEditSessionTVC
    }

    static func makeDashboardCVC(
        layout: UICollectionViewLayout = UICollectionViewFlowLayout(),
        user: User?) -> DashboardCVC {
        let dashboardCVC = DashboardCVC(
            collectionViewLayout: layout)
        dashboardCVC.customDataSource = DashboardCVDS(
            listDataSource: dashboardCVC,
            user: user)
        dashboardCVC.customDelegate = DashboardCVD(
            listDelegate: dashboardCVC)
        return dashboardCVC
    }

    static func makeExercisePreviewVC(exercise: Exercise,
                                      exercisesTVDS: ExercisesTVDS?
    ) -> ExercisePreviewVC {
        let exercisePreviewVC = ExercisePreviewVC(
            exercisesTVDS: exercisesTVDS)
        exercisePreviewVC.customDataSource = ExercisePreviewTVDS()
        exercisePreviewVC.customDataSource?.exercise = exercise
        exercisePreviewVC.customDelegate = ExercisePreviewTVD()
        exercisePreviewVC.customDelegate?.exercise = exercise
        return exercisePreviewVC
    }

    static func makeExercisesVC(
        presentationStyle: PresentationStyle = .normal,
        exerciseUpdatingDelegate: ExerciseUpdatingDelegate? = nil,
        exercisesTVDS: ExercisesTVDS? = nil,
        sessionsCVDS: SessionsCVDS? = nil
    ) -> ExercisesVC {
        let exercisesVC = ExercisesVC()
        exercisesVC.exerciseUpdatingDelegate = exerciseUpdatingDelegate
        exercisesVC.sessionsCVDS = sessionsCVDS
        if exercisesTVDS == nil {
            exercisesVC.customDataSource = ExercisesTVDS(
                listDataSource: exercisesVC)
        } else {
            exercisesVC.customDataSource = exercisesTVDS
            exercisesTVDS?.prepareForReuse(newListDataSource: exercisesVC)
        }
        exercisesVC.customDataSource?.presentationStyle = presentationStyle
        exercisesVC.customDelegate = ExercisesTVD(
            listDelegate: exercisesVC)
        return exercisesVC
    }

    static func makeMainNC(
        rootVC: UIViewController,
        transitioningDelegate: TransitioningDelegate? = nil,
        modalTransitionStyle: UIModalTransitionStyle? = .crossDissolve
    ) -> MainNC {
        let mainNC = MainNC(rootVC: rootVC)
        if transitioningDelegate != nil {
            mainNC.modalPresentationStyle = .custom
            if let transitionStyle = modalTransitionStyle {
                mainNC.modalTransitionStyle = transitionStyle
            }
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

    static func makeOnboardingVC(user: User?) -> OnboardingVC {
        let onboardingVC = OnboardingVC(user: user)
        onboardingVC.modalPresentationStyle = .overCurrentContext
        onboardingVC.modalTransitionStyle = .crossDissolve
        return onboardingVC
    }

    static func makeProfileTVC(style: UITableView.Style,
                               user: User?) -> ProfileTVC {
        let profileTVC = ProfileTVC(style: style)
        profileTVC.customDataSource = ProfileTVDS(
            listDataSource: profileTVC,
            user: user)
        profileTVC.customDelegate = ProfileTVD(
            listDelegate: profileTVC)
        return profileTVC
    }

    static func makeRestVC(
        startedSessionTimers: StartedSessionTimers?
    ) -> RestVC {
        let restVC = RestVC()
        restVC.startedSessionTimers = startedSessionTimers
        restVC.startedSessionTimers?
            .startedSessionTimerDelegates?.append(restVC)
        restVC.customDSAndD = RestDSAndD()
        return restVC
    }

    static func makeSelectionTVC(items: [String],
                                 selected: String,
                                 title: String = "Selection",
                                 delegate: SelectionDelegate?) -> SelectionTVC {
        let selectionTVC = SelectionTVC(title: title)
        selectionTVC.customDataSource = SelectionTVDS(items: items,
                                                      selected: selected)
        selectionTVC.customDataSource?.selectionDelegate = delegate
        selectionTVC.customDelegate = SelectionTVD(
            listDelegate: selectionTVC)
        return selectionTVC
    }

    static func makeSessionPreviewTVC(session: Session,
                                      delegate: SessionProgressDelegate?,
                                      exercisesTVDS: ExercisesTVDS?,
                                      sessionsCVDS: SessionsCVDS?) -> SessionPreviewTVC {
        let sessionPreviewTVC = SessionPreviewTVC()
        sessionPreviewTVC.sessionProgressDelegate = delegate
        sessionPreviewTVC.exercisesTVDS = exercisesTVDS
        sessionPreviewTVC.sessionsCVDS = sessionsCVDS
        sessionPreviewTVC.customDataSource = SessionPreviewTVDS()
        sessionPreviewTVC.customDataSource?.session = session
        sessionPreviewTVC.customDelegate = SessionPreviewTVD()
        return sessionPreviewTVC
    }

    static func makeSessionsCVC(
        layout: UICollectionViewLayout = UICollectionViewFlowLayout(),
        user: User?
    ) -> SessionsCVC {
        let sessionsCVC = SessionsCVC(
            collectionViewLayout: layout)
        sessionsCVC.customDataSource = SessionsCVDS(
            listDataSource: sessionsCVC,
            user: user)
        sessionsCVC.customDelegate = SessionsCVD(
            listDelegate: sessionsCVC)
        return sessionsCVC
    }

    static func makeSettingsTVC(style: UITableView.Style,
                                user: User?) -> SettingsTVC {
        let settingsTVC = SettingsTVC(style: style)
        settingsTVC.customDataSource = SettingsTVDS(user: user)
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

    //swiftlint:disable:next function_parameter_count
    static func makeStartedSessionTVC(style: UITableView.Style,
                                      session: Session?,
                                      exercisesTVDS: ExercisesTVDS?,
                                      delegate: SessionProgressDelegate?,
                                      blurredView: UIVisualEffectView,
                                      panView: UIView,
                                      initialTabBarFrame: CGRect) -> StartedSessionTVC {
        let startedSessionTVC = StartedSessionTVC(style: style)
        startedSessionTVC.exercisesTVDS = exercisesTVDS
        startedSessionTVC.blurredView = blurredView
        startedSessionTVC.panView = panView
        startedSessionTVC.initialTabBarFrame = initialTabBarFrame
        startedSessionTVC.startedSessionTimers = StartedSessionTimers(
            timerDelegate: startedSessionTVC)
        startedSessionTVC.customDataSource = StartedSessionTVDS(
            listDataSource: startedSessionTVC)
        startedSessionTVC.customDataSource?.session = session
        startedSessionTVC.customDataSource?.sessionProgresssDelegate = delegate
        startedSessionTVC.customDelegate = StartedSessionTVD(
            listDelegate: startedSessionTVC)
        startedSessionTVC.customDelegate?.session = session
        return startedSessionTVC
    }
}
