//
//  CreateEditExerciseDataModel.swift
//  Gymbo
//
//  Created by Rohan Sharma on 11/21/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: - Properties
struct CreateEditExerciseDataModel {
    private let tableItems: [[TableItem]] = [
        [
            .nameTitle, .name, .muscleGroupsTitle,
            .muscleGroups, .imagesTitle, .images,
            .instructionsTitle, .instructions, .tipsTitle,
            .tips
        ]
    ]

    var exercise = Exercise()

    // Data stored from cell inputs
    var exerciseName: String?
    var groups: [String]?
    var images: [UIImage]?
    var instructions: String?
    var tips: String?
}

// MARK: - Structs/Enums
extension CreateEditExerciseDataModel {
    private struct Constants {
        static let muscleGroupsCellHeight = CGFloat(150)
        static let imagesCellHeight = CGFloat(100)
    }

    enum TableItem: String {
        case nameTitle = "Exercise Name"
        case name
        case muscleGroupsTitle = "Muscle Groups"
        case muscleGroups
        case imagesTitle = "Images (Optional)"
        case images
        case instructionsTitle = "Instructions (Optional)"
        case instructions
        case tipsTitle = "Tips (Optional)"
        case tips

        var height: CGFloat {
            switch self {
            case .nameTitle, .name, .muscleGroupsTitle,
                 .imagesTitle, .instructionsTitle, .instructions,
                 .tipsTitle, .tips:
                return UITableView.automaticDimension
            case .muscleGroups:
                return Constants.muscleGroupsCellHeight
            case .images:
                return Constants.imagesCellHeight
            }
        }
    }
}

// MARK: - Funcs
extension CreateEditExerciseDataModel {
    mutating func setupFromExistingExercise() {
        exerciseName = exercise.name ?? ""
        groups = (exercise.groups ?? "").components(separatedBy: ",").map {
            $0.capitalized.trimmingCharacters(in: .whitespaces)
        }
        images = getUIImageFromImageNames(list: exercise.imageNames)
        instructions = exercise.instructions ?? ""
        tips = exercise.tips ?? ""
    }

    private func getUIImageFromImageNames(list: List<String>) -> [UIImage] {
        var images = [UIImage]()
        for imageName in list {
            if let imageToAdd = Utility.getImageFrom(name: imageName,
                                                     directory: .userImages) {
                images.append(imageToAdd)
            }
        }
        return images
    }

    // MARK: - UITableViewCells
    private func getLabelTVCell(in tableView: UITableView,
                                for indexPath: IndexPath,
                                item: TableItem) -> LabelTVCell {
        guard let labelTVCell = tableView.dequeueReusableCell(
                withIdentifier: LabelTVCell.reuseIdentifier,
                for: indexPath) as? LabelTVCell else {
            fatalError("Could not dequeue \(LabelTVCell.reuseIdentifier)")
        }

        labelTVCell.configure(text: item.rawValue, font: UIFont.large.medium)
        return labelTVCell
    }

    private func getTextFieldTVCell(in tableView: UITableView,
                                    for indexPath: IndexPath) -> TextFieldTVCell {
        guard let textFieldTVCell = tableView.dequeueReusableCell(
            withIdentifier: TextFieldTVCell.reuseIdentifier,
            for: indexPath) as? TextFieldTVCell else {
            fatalError("Could not dequeue \(TextFieldTVCell.reuseIdentifier)")
        }

        textFieldTVCell.configure(text: exerciseName ?? (exercise.name ?? ""),
                                  placeHolder: "Exercise name...")
        return textFieldTVCell
    }

    private func getMultipleSelectionCell(in tableView: UITableView,
                                          for indexPath: IndexPath) -> MultipleSelectionTVCell {
        guard let multipleSelectionTVCell = tableView.dequeueReusableCell(
                withIdentifier: MultipleSelectionTVCell.reuseIdentifier,
                for: indexPath) as? MultipleSelectionTVCell else {
            fatalError("Could not dequeue \(MultipleSelectionTVCell.reuseIdentifier)")
        }

        let selectedTitlesArray = (exercise.groups ?? "").components(separatedBy: ",").map {
            $0.capitalized.trimmingCharacters(in: .whitespaces)
        }
        let selectedGroups = groups ?? selectedTitlesArray
        multipleSelectionTVCell.configure(titles: ExerciseDataModel().defaultExerciseGroups,
                                          selectedTitles: selectedGroups)
        return multipleSelectionTVCell
    }

    private func getImagesCell(in tableView: UITableView,
                               for indexPath: IndexPath) -> ImagesTVCell {
        guard let imagesTVCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesTVCell.reuseIdentifier,
            for: indexPath) as? ImagesTVCell else {
            fatalError("Could not dequeue \(ImagesTVCell.reuseIdentifier)")
        }

        let existingImages = getUIImageFromImageNames(list: exercise.imageNames)
        let defaultImage = UIImage(named: "add")
        imagesTVCell.configure(existingImages: existingImages,
                               defaultImage: defaultImage,
                               type: .button)
        return imagesTVCell
    }

    private func getTextViewCell(in tableView: UITableView,
                                 for indexPath: IndexPath,
                                 item: TableItem) -> TextViewTVCell {
        guard let textViewTVCell = tableView.dequeueReusableCell(
                withIdentifier: TextViewTVCell.reuseIdentifier,
                for: indexPath) as? TextViewTVCell else {
            fatalError("Could not dequeue \(TextViewTVCell.reuseIdentifier)")
        }

        let text: String
        if item == .instructions {
            text = instructions ?? (exercise.instructions ?? "")
        } else {
            text = tips ?? (exercise.tips ?? "")
        }
        textViewTVCell.configure(text: text)
        return textViewTVCell
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
extension CreateEditExerciseDataModel {
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
        case .nameTitle, .muscleGroupsTitle, .imagesTitle, .instructionsTitle, .tipsTitle:
            cell = getLabelTVCell(in: tableView, for: indexPath, item: item)
        case .name:
            cell = getTextFieldTVCell(in: tableView, for: indexPath)
        case .muscleGroups:
            cell = getMultipleSelectionCell(in: tableView, for: indexPath)
        case .images:
            cell = getImagesCell(in: tableView, for: indexPath)
        case .instructions, .tips:
            cell = getTextViewCell(in: tableView, for: indexPath, item: item)
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
        return tableItems[indexPath.section][indexPath.row].height
    }
}
