//
//  StartedSessionTVC+StartedSessionButtonDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartedSessionTVC: StartedSessionButtonDelegate {
    func addExercise() {
        Haptic.sendSelectionFeedback()
        customDataSource?.modallyPresenting = .exercisesVC

        let exercisesVC = VCFactory.makeExercisesVC(presentationStyle: .modal,
                                                    exerciseUpdatingDelegate: self,
                                                    exercisesTVDS: exercisesTVDS)
        let modalNC = VCFactory.makeMainNC(rootVC: exercisesVC,
                                           transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)
    }

    func cancelSession() {
        Haptic.sendImpactFeedback(.heavy)
        let rightButtonAction = { [weak self] in
            Haptic.sendImpactFeedback(.heavy)
            DispatchQueue.main.async {
                self?.dismissAsChildViewController(endType: .cancel)
            }
        }
        let alertData = AlertData(title: "Cancel Session",
                                  content: "Do you want to cancel the session?",
                                  leftButtonTitle: "No",
                                  rightButtonTitle: "Yes",
                                  rightButtonAction: rightButtonAction)
        presentCustomAlert(alertData: alertData)
    }
}
