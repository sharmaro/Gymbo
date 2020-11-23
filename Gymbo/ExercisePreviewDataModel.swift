//
//  ExercisePreviewDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/22/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
struct ExercisePreviewDataModel {
    private let tableItems: [[TableItem]] = [
        [
            .title, .imagesTitle, .images,
            .instructionsTitle, .instructions, .tipsTitle,
            .tips
        ]
    ]

    var exercise = Exercise()
}

// MARK: - Structs/Enums
extension ExercisePreviewDataModel {
    private struct Constants {
        static let swipableImageViewTableViewCellHeight = CGFloat(200)

        static let noImagesText = "No images\n"
        static let noInstructionsText = "No instructions\n"
        static let noTipsText = "No tips\n"
    }

    enum TableItem: String {
        case imagesTitle = "Images"
        case images
        case instructionsTitle = "Instructions"
        case instructions
        case tipsTitle = "Tips"
        case tips
        case title
    }
}

// MARK: - Funcs
extension ExercisePreviewDataModel {
    // MARK: - UITableViewCells
    private func getTwoLabelsCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> TwoLabelsTableViewCell {
        guard let twoLabelsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TwoLabelsTableViewCell.reuseIdentifier,
            for: indexPath) as? TwoLabelsTableViewCell else {
            fatalError("Could not dequeue \(TwoLabelsTableViewCell.reuseIdentifier)")
        }

        twoLabelsTableViewCell.configure(topText: exercise.name ?? "", bottomText: exercise.groups ?? "")
        return twoLabelsTableViewCell
    }

    private func getLabelCell(in tableView: UITableView,
                              for indexPath: IndexPath,
                              text: String,
                              font: UIFont = .normal) -> LabelTableViewCell {
        guard let labelTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: LabelTableViewCell.reuseIdentifier,
            for: indexPath) as? LabelTableViewCell else {
            fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
        }

        labelTableViewCell.configure(text: text, font: font)
        return labelTableViewCell
    }

    private func getSwipableImageViewCell(in tableView: UITableView,
                                          for indexPath: IndexPath) -> SwipableImageViewTableViewCell {
        guard let swipableImageViewCell = tableView.dequeueReusableCell(
            withIdentifier: SwipableImageViewTableViewCell.reuseIdentifier,
            for: indexPath) as? SwipableImageViewTableViewCell else {
            fatalError("Could not dequeue \(SwipableImageViewTableViewCell.reuseIdentifier)")
        }

        let imageFileNames = Array(exercise.imageNames)
        swipableImageViewCell.configure(imageFileNames: imageFileNames,
                                        isUserMade: exercise.isUserMade)
        return swipableImageViewCell
    }

    // MARK: - Helpers
    private func validateSection(section: Int) -> Bool {
        section < tableItems.count
    }

    func indexOf(item: TableItem) -> Int? {
        var index: Int?
        tableItems.forEach {
            if $0.contains(item) {
                index = $0.firstIndex(of: item)
                return
            }
        }
        return index
    }
}

// MARK: - UITableViewDataSource
extension ExercisePreviewDataModel {
    var numberOfSections: Int {
        tableItems.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard validateSection(section: section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }
        return tableItems[section].count
    }

    func cellForRow(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }

        let cell: UITableViewCell
        let item = tableItems[indexPath.section][indexPath.row]

        switch item {
        case .title:
            cell = getTwoLabelsCell(in: tableView, for: indexPath)
        case .imagesTitle, .instructionsTitle, .tipsTitle:
            cell = getLabelCell(in: tableView,
                                for: indexPath,
                                text: item.rawValue,
                                font: UIFont.large.medium)
        case .images:
            if exercise.imageNames.isEmpty {
                cell = getLabelCell(in: tableView, for: indexPath, text: Constants.noImagesText)
            } else {
                cell = getSwipableImageViewCell(in: tableView, for: indexPath)
            }
        case .instructions, .tips:
            let text = item == .instructions ? exercise.instructions : exercise.tips
            let emptyText = item == .instructions ? Constants.noInstructionsText : Constants.noTipsText
            cell = getLabelCell(in: tableView,
                                for: indexPath,
                                text: text ?? emptyText)
        }
        return cell
    }

    func tableItem(at indexPath: IndexPath) -> TableItem {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }
        return tableItems[indexPath.section][indexPath.row]
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        guard validateSection(section: indexPath.section) else {
            fatalError("Section is greater than tableItem.count of \(tableItems.count)")
        }

        let item = tableItems[indexPath.section][indexPath.row]
        switch item {
        case .images:
            return exercise.imageNames.isEmpty ?
                UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
}
