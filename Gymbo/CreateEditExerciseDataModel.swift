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

    private func getLabelTableViewCell(in tableView: UITableView,
                                       for indexPath: IndexPath,
                                       item: TableItem) -> LabelTableViewCell {
        guard let labelTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: LabelTableViewCell.reuseIdentifier,
            for: indexPath) as? LabelTableViewCell else {
            fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
        }

        labelTableViewCell.configure(text: item.rawValue, font: UIFont.large.medium)
        return labelTableViewCell
    }

    private func getTextFieldCell(in tableView: UITableView,
                                  for indexPath: IndexPath) -> TextFieldTableViewCell {
        guard let textFieldTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TextFieldTableViewCell.reuseIdentifier,
            for: indexPath) as? TextFieldTableViewCell else {
            fatalError("Could not dequeue \(TextFieldTableViewCell.reuseIdentifier)")
        }

        textFieldTableViewCell.configure(text: exerciseName ?? (exercise.name ?? ""),
                                         placeHolder: "Exercise name...")
        return textFieldTableViewCell
    }

    private func getMultipleSelectionCell(in tableView: UITableView,
                                          for indexPath: IndexPath) -> MultipleSelectionTableViewCell {
        guard let multipleSelectionTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: MultipleSelectionTableViewCell.reuseIdentifier,
            for: indexPath) as? MultipleSelectionTableViewCell else {
            fatalError("Could not dequeue \(MultipleSelectionTableViewCell.reuseIdentifier)")
        }

        let selectedTitlesArray = (exercise.groups ?? "").components(separatedBy: ",").map {
            $0.capitalized.trimmingCharacters(in: .whitespaces)
        }
        let selectedGroups = groups ?? selectedTitlesArray
        multipleSelectionTableViewCell.configure(titles: ExerciseDataModel().defaultExerciseGroups,
                                                 selectedTitles: selectedGroups)
        return multipleSelectionTableViewCell
    }

    private func getImagesCell(in tableView: UITableView,
                               for indexPath: IndexPath) -> ImagesTableViewCell {
        guard let imagesTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesTableViewCell.reuseIdentifier,
            for: indexPath) as? ImagesTableViewCell else {
            fatalError("Could not dequeue \(ImagesTableViewCell.reuseIdentifier)")
        }

        let existingImages = getUIImageFromImageNames(list: exercise.imageNames)
        let defaultImage = UIImage(named: "add")
        imagesTableViewCell.configure(existingImages: existingImages,
                                      defaultImage: defaultImage,
                                      type: .button)
        return imagesTableViewCell
    }

    private func getTextViewCell(in tableView: UITableView,
                                 for indexPath: IndexPath,
                                 item: TableItem) -> TextViewTableViewCell {
        guard let textViewTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TextViewTableViewCell.reuseIdentifier,
            for: indexPath) as? TextViewTableViewCell else {
            fatalError("Could not dequeue \(TextViewTableViewCell.reuseIdentifier)")
        }

        let text: String
        if item == .instructions {
            text = instructions ?? (exercise.instructions ?? "")
        } else {
            text = tips ?? (exercise.tips ?? "")
        }
        textViewTableViewCell.configure(text: text)
        return textViewTableViewCell
    }

    // Helpers
    private func validateSection(section: Int) -> Bool {
        section < tableItems.count
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
            cell = getLabelTableViewCell(in: tableView, for: indexPath, item: item)
        case .name:
            cell = getTextFieldCell(in: tableView, for: indexPath)
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
