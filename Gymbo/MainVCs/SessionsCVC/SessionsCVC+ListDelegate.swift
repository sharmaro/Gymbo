//
//  SessionsCVC+ListDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension SessionsCVC: ListDelegate {
    func didSelectItem(at indexPath: IndexPath) {
        guard customDataSource?.dataState == .notEditing,
              let selectedSession = customDataSource?.session(for: indexPath.row) else {
                Haptic.sendNotificationFeedback(.warning)
                return
        }
        Haptic.sendSelectionFeedback()

        let sessionPreviewTVC = VCFactory.makeSessionPreviewTVC(session: selectedSession,
                                                                delegate: mainTBC,
                                                                exercisesTVDS: exercisesTVDS,
                                                                sessionsCVDS: customDataSource)
        let modalNavigationController = MainNC(rootVC: sessionPreviewTVC)
        present(modalNavigationController, animated: true)
    }
}
