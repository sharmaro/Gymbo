//
//  AllSessionsDetailTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionsDetailTVDS: NSObject {
    private let session: Session?

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?, session: Session?) {
        self.session = session
        super.init()
        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension AllSessionsDetailTVDS {
    private struct Constants {
        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "Info"
    }
}

// MARK: - Funcs
extension AllSessionsDetailTVDS {
    func sessionHVDataModel() -> SessionDetailHeaderModel {
        var dataModel = SessionDetailHeaderModel()
        dataModel.firstText = session?.name ?? "Constants.namePlaceholderText"
        dataModel.secondText = session?.info ?? "Constants.infoPlaceholderText"
        dataModel.dateText = session?.dateCompleted?.formattedString(type: .long)
        dataModel.firstImage = UIImage(named: "stopwatch")?
            .withRenderingMode(.alwaysTemplate)
        dataModel.firstImageText = session?.sessionSeconds.neatTimeString ?? ""
        dataModel.secondImage = UIImage(named: "dumbbell")?
            .withRenderingMode(.alwaysTemplate)
        dataModel.secondImageText = "\(session?.totalWeight ?? 0) lbs"
        return dataModel
    }
}

// MARK: - UITableViewDataSource
extension AllSessionsDetailTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        session?.exercises.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // +1 for exercise name
        (session?.exercises[section].sets ?? 0) + 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LabelTVCell.reuseIdentifier,
                for: indexPath) as? LabelTVCell,
              let exercise = session?.exercises[indexPath.section] else {
            fatalError("Could not dequeue \(LabelTVCell.reuseIdentifier)")
        }

        let text: String
        let font: UIFont
        if indexPath.row == 0 {
            text = exercise.name ?? ""
            font = UIFont.medium.semibold
        } else {
            let set = "\(indexPath.row)"
            var reps = exercise.exerciseDetails[indexPath.row - 1].reps ?? ""
            if reps.isEmpty {
                reps = "0"
            }

            var weight = exercise.exerciseDetails[indexPath.row - 1].weight ?? ""
            if weight.isEmpty {
                weight = "0"
            }
            text = "\(set) \t \(reps) x \(weight) lbs"
            font = UIFont.normal.light
        }
        cell.configure(text: text, font: font)
        return cell
    }
}
