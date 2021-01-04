//
//  MainTBDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/27/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class MainTBDS: NSObject {
    var selectedTab = Tab.sessions
    var viewControllers: [MainNC]?
    private(set)var user: User?

    private(set)var exercisesTVDS: ExercisesTVDS? {
        get {
            exercisesTVC?.customDataSource
        }
        set {
            exercisesTVC?.customDataSource = newValue
        }
    }

    private var exercisesTVC: ExercisesTVC? {
        let mainNC = viewControllers?[Tab.exercises.rawValue]
        return (mainNC?.rootVC as? ExercisesTVC)
    }

    override init() {
        super.init()

        setupUser()
        setupVCs()
    }
}

// MARK: - Structs/Enums
extension MainTBDS {
    //swiftlint:disable:next type_name
    enum Tab: Int, CaseIterable {
        case profile
        case dashboard
        case sessions
        case exercises
        case stopwatch

        var title: String {
            let text: String
            switch self {
            case .profile:
                text = "Profile"
            case .dashboard:
                text = "Dashboard"
            case .sessions:
                text = "Sessions"
            case .exercises:
                text = "My Exercises"
            case .stopwatch:
                text = "Stopwatch"
            }
            return text
        }

        var image: UIImage {
            let imageName: String
            switch self {
            case .profile:
                imageName = "profile"
            case .dashboard:
                imageName = "dashboard"
            case .sessions:
                imageName = "dumbbell"
            case .exercises:
                imageName = "my_exercises"
            case .stopwatch:
                imageName = "stopwatch"
            }
            return UIImage(named: imageName) ?? UIImage()
        }
    }
}

// MARK: - Funcs
extension MainTBDS {
    private func setupUser() {
        let realm = try? Realm()
        if let user = realm?.objects(User.self).first {
            self.user = user
        } else {
            try? realm?.write {
                realm?.add(User())
            }
            self.user = realm?.objects(User.self).first
        }
    }

    private func setupVCs() {
        let profileTVC = VCFactory.makeProfileTVC(user: user)
        // Need to initialize a UICollectionView with a UICollectionViewLayout
        let dashboardCVC = VCFactory.makeDashboardCVC(
            user: user)
        let sessionsCVC = VCFactory.makeSessionsCVC(user: user)
        let exercisesTVC = VCFactory.makeExercisesTVC(
            style: .grouped,
            sessionsCVDS: sessionsCVC.customDataSource)
        sessionsCVC.exercisesTVDS = exercisesTVC.customDataSource
        let stopwatchVC = VCFactory.makeStopwatchVC()

        let vcs = [profileTVC, dashboardCVC, sessionsCVC,
                   exercisesTVC, stopwatchVC]
        for (index, tab) in Tab.allCases.enumerated() {
            let vc = vcs[index]
            vc.tabBarItem = UITabBarItem(title: tab.title,
                                         image: tab.image,
                                         tag: tab.rawValue)
        }
        viewControllers = vcs.map { MainNC(rootVC: $0) }
    }
}

// MARK: - UITabBarControllerDelegate
extension MainTBDS: UITabBarControllerDelegate {
    public func tabBarController(_ tabBarController: UITabBarController,
                                 didSelect viewController: UIViewController) {
        selectedTab = Tab(rawValue: tabBarController.selectedIndex) ?? .sessions

        guard exercisesTVC != nil,
              selectedTab == .exercises else {
            return
        }
        exercisesTVDS?.prepareForReuse(newListDataSource: nil)
    }
}
