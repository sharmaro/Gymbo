//
//  StartedSessionTVC+ExerciseUpdatingDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

extension StartedSessionTVC: ExerciseUpdatingDelegate {
    func updateExercises(_ exercises: [Exercise]) {
        customDataSource?.updateExercises(exercises)
        tableView.reloadWithoutAnimation()
        // Update SessionsCVC
        NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
    }
}
