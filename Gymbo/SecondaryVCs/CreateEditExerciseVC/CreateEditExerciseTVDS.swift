//
//  CreateEditExerciseTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class CreateEditExerciseTVDS: NSObject {
    // Data stored from cell inputs
    var exerciseName: String?
    var groups: [String]?
    var images: [UIImage]?
    var instructions: String?
    var tips: String?

    var exercise = Exercise() {
        didSet {
            setupFromExercise()
        }
    }

    private let sections = Section.allCases

    private let items: [[Item]] = [
        [.name],
        [.muscleGroups],
        [.images],
        [.instructions],
        [.tips]
    ]

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?) {
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension CreateEditExerciseTVDS {
    private struct Constants {
        static let muscleGroupsCellHeight = CGFloat(150)
        static let imagesCellHeight = CGFloat(100)
    }

    enum Section: String, CaseIterable {
        case name = "Exercise Name"
        case muscleGroups = "Muscle Groups"
        case images = "Images (Optional)"
        case instructions = "Instructions (Optional)"
        case tips = "Tips (Optional)"
    }

    enum Item: String {
        case name
        case muscleGroups
        case images
        case instructions
        case tips

        var height: CGFloat {
            let response: CGFloat
            switch self {
            case .name, .instructions, .tips:
                response = UITableView.automaticDimension
            case .muscleGroups:
                response = Constants.muscleGroupsCellHeight
            case .images:
                response = Constants.imagesCellHeight
            }
            return response
        }
    }
}

// MARK: - Funcs
extension CreateEditExerciseTVDS {
    private func setupFromExercise() {
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
        let defaultGroups = ExerciseLoader.shared.exerciseGroups
        multipleSelectionTVCell.configure(titles: defaultGroups,
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
                                 item: Item) -> TextViewTVCell {
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

    func indexPathOf(item: Item) -> IndexPath? {
        var indexPath: IndexPath?
        for (section, value) in items.enumerated() {
            if value.contains(item) {
                if let row = value.firstIndex(of: item) {
                    indexPath = IndexPath(row: row, section: section)
                    return indexPath
                }
            }
        }
        return indexPath
    }

    func item(at indexPath: IndexPath) -> Item {
        return items[indexPath.section][indexPath.row]
    }

    func getImageNamesAfterSave() -> List<String> {
        guard let exerciseName = exerciseName,
              let images = images else {
            return List<String>()
        }

        let imageNames = Utility.saveImages(name: exerciseName,
                                                images: images,
                                                isUserMade: true,
                                                directory: .userImages) ?? [""]

        let thumbnails = images.map { $0.thumbnail ?? UIImage() }
        Utility.saveImages(name: exerciseName,
                           images: thumbnails,
                           isUserMade: true,
                           directory: .userThumbnails)

        let imageFilePathsList = List<String>()
        imageFilePathsList.append(objectsIn: imageNames)
        return imageFilePathsList
    }

    func getFormattedGroups() -> String? {
        guard var dataModelGroups = groups else {
            return nil
        }

        dataModelGroups.sort()

        var groups = ""
        for (index, name) in dataModelGroups.enumerated() {
            let groupName = name.lowercased()
            if index < dataModelGroups.count - 1 {
                groups += "\(groupName), "
            } else {
                groups += "\(groupName)"
            }
        }
        return groups
    }
}

// MARK: - UITableViewDataSource
extension CreateEditExerciseTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let item = items[indexPath.section][indexPath.row]

        switch item {
        case .name:
            cell = getTextFieldTVCell(in: tableView, for: indexPath)
        case .muscleGroups:
            cell = getMultipleSelectionCell(in: tableView, for: indexPath)
        case .images:
            cell = getImagesCell(in: tableView, for: indexPath)
        case .instructions, .tips:
            cell = getTextViewCell(in: tableView, for: indexPath, item: item)
        }

        listDataSource?.cellForRowAt(tvCell: cell)
        Utility.configureCellRounding(in: tableView,
                                      with: cell,
                                      for: indexPath)
        return cell
    }
}
