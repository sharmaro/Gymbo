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
        static let swipableImageVTVCellHeight = CGFloat(200)

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
    private func getTwoLabelsTVCell(in tableView: UITableView,
                                    for indexPath: IndexPath) -> TwoLabelsTVCell {
        guard let twoLabelsTVCell = tableView.dequeueReusableCell(
                withIdentifier: TwoLabelsTVCell.reuseIdentifier,
                for: indexPath) as? TwoLabelsTVCell else {
            fatalError("Could not dequeue \(TwoLabelsTVCell.reuseIdentifier)")
        }

        twoLabelsTVCell.configure(topText: exercise.name ?? "", bottomText: exercise.groups ?? "")
        return twoLabelsTVCell
    }

    private func getLabelCell(in tableView: UITableView,
                              for indexPath: IndexPath,
                              text: String,
                              font: UIFont = .normal) -> LabelTVCell {
        guard let labelTVCell = tableView.dequeueReusableCell(
                withIdentifier: LabelTVCell.reuseIdentifier,
                for: indexPath) as? LabelTVCell else {
            fatalError("Could not dequeue \(LabelTVCell.reuseIdentifier)")
        }

        labelTVCell.configure(text: text, font: font)
        return labelTVCell
    }

    private func getSwipableImageViewCell(in tableView: UITableView,
                                          for indexPath: IndexPath) -> SwipableImageVTVCell {
        guard let swipableImageVTVCell = tableView.dequeueReusableCell(
            withIdentifier: SwipableImageVTVCell.reuseIdentifier,
            for: indexPath) as? SwipableImageVTVCell else {
            fatalError("Could not dequeue \(SwipableImageVTVCell.reuseIdentifier)")
        }

        let imageFileNames = Array(exercise.imageNames)
        swipableImageVTVCell.configure(imageFileNames: imageFileNames,
                                       isUserMade: exercise.isUserMade)
        return swipableImageVTVCell
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
            cell = getTwoLabelsTVCell(in: tableView, for: indexPath)
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
                UITableView.automaticDimension : Constants.swipableImageVTVCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
}
