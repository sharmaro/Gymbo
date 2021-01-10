//
//  ExercisePreviewTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisePreviewTVD: NSObject {
    var exercise = Exercise()

    private let sectionTitles = ExercisePreviewTVDS.Section.allCases.map { $0.rawValue }

    private let items: [[ExercisePreviewTVDS.Item]] = [
        [.title],
        [.images],
        [.instructions],
        [.tips]
    ]
}

// MARK: - Structs/Enums
private extension ExercisePreviewTVD {
    struct Constants {
        static let headerHeight = CGFloat(40)
        static let swipableImageVTVCellHeight = CGFloat(200)
    }
}

// MARK: - Funcs
extension ExercisePreviewTVD {
    private func height(for item: ExercisePreviewTVDS.Item) -> CGFloat {
        if item == .images {
            return exercise.imageNames.isEmpty ?
                UITableView.automaticDimension : Constants.swipableImageVTVCellHeight
        }
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension ExercisePreviewTVD: UITableViewDelegate {
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
        height(for: items[indexPath.section][indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        height(for: items[indexPath.section][indexPath.row])
    }
}
