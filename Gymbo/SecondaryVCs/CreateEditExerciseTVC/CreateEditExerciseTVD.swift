//
//  CreateEditExerciseTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class CreateEditExerciseTVD: NSObject {
    private let sectionTitles = CreateEditExerciseTVDS.Section.allCases.map { $0.rawValue }

    private let items: [[CreateEditExerciseTVDS.Item]] = [
        [.name],
        [.muscleGroups],
        [.images],
        [.instructions],
        [.tips]
    ]
}

// MARK: - Structs/Enums
private extension CreateEditExerciseTVD {
    struct Constants {
        static let headerHeight = CGFloat(40)
    }
}

// MARK: - UITableViewDelegate
extension CreateEditExerciseTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let exercisesHFV = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: ExercisesHFV.reuseIdentifier)
                as? ExercisesHFV else {
            fatalError("Could not dequeue \(ExercisesHFV.reuseIdentifier)")
        }

        let title =  sectionTitles[section]
        exercisesHFV.configure(title: title)
        return exercisesHFV
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        items[indexPath.section][indexPath.row].height
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        items[indexPath.section][indexPath.row].height
    }
}
