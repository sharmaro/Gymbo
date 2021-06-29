//
//  AppDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        setupKeyWindow()
//        NotificationHelper.requestPermission()
        setupUINavigationBarAppearance()
        setupUITableViewAppearance()
        setupUICollectionViewAppearance()
        setupUserInterfaceMode()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        /*
         - Sent when the application is about to move from active to inactive state.
         This can occur for certain types of temporary interruptions
         (such as an incoming phone call or SMS message) or when the user quits
         the application and it begins the transition to the background state.
         - Use this method to pause ongoing tasks, disable timers,
         and invalidate graphics rendering callbacks.
         Games should use this method to pause the game.
         */
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        /*
         - Use this method to release shared resources,
         save user data, invalidate timers, and store enough application state
         information to restore your application to its current
         state in case it is terminated later.
         - If your application supports background execution,
         this method is called instead of applicationWillTerminate:
         when the user quits.
         */
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        /*
         Called as part of the transition from the background to
         the active state; here you can undo many of the
         changes made on entering the background.
         */
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        /*
         Restart any tasks that were paused (or not yet started)
         while the application was inactive.
         If the application was previously in the background, optionally refresh the user interface.
         */
//        NotificationHelper.clearBadge()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        /*
         Called when the application is about to terminate.
         Save data if appropriate. See also applicationDidEnterBackground:.
         */
    }
}

// MARK: - Funcs
extension AppDelegate {
    private func setupKeyWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)

        let mainTBC = VCFactory.makeMainTBC()
        window?.rootViewController = mainTBC
        window?.makeKeyAndVisible()
    }

    private func setupUINavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .primaryBackground
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.primaryText]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryText]

        /*
         - Don't want to mess up delegate UINavigationControllers for
         - things like the email VC and the Photo Library image picker
         */
        let navigationBarAppearance = UINavigationBar.appearance(
            whenContainedInInstancesOf: [MainNC.self])
        navigationBarAppearance.standardAppearance = appearance
        navigationBarAppearance.compactAppearance = appearance
        navigationBarAppearance.scrollEdgeAppearance = appearance
        navigationBarAppearance.prefersLargeTitles = true
        navigationBarAppearance.isTranslucent = false
    }

    private func setupUITableViewAppearance() {
        UITableView.appearance().showsHorizontalScrollIndicator = false
        UITableView.appearance().showsVerticalScrollIndicator = false
    }

    private func setupUICollectionViewAppearance() {
        UICollectionView.appearance().showsHorizontalScrollIndicator = false
        UICollectionView.appearance().showsVerticalScrollIndicator = false
    }

    private func setupUserInterfaceMode() {
        UserInterfaceMode.setUserInterfaceMode(with: .currentMode)
    }
}
