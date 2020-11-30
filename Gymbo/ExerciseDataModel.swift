//
//  ExerciseDataModelManager.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class ExerciseDataModel: NSObject {
    private var realm: Realm? {
        try? Realm()
    }

    private let exerciseGroups = ["Abs", "Arms", "Back", "Chest",
                                  "Glutes", "Hips", "Legs", "Other",
                                  "Shoulders"]

    private var exercises: [Exercise] {
        Array(realm?.objects(ExercisesList.self).first?.exercises ?? List<Exercise>())
    }

    // Used to store the filtered results based on user search
    private var searchResults = ""

    var sectionTitles: [String] {
        Array(self.realm?.objects(ExercisesList.self).first?.sectionTitles ?? List<String>())
    }

    weak var dataFetchDelegate: DataFetchDelegate?
}

// MARK: - Structs/Enums
private extension ExerciseDataModel {
    struct Constants {
        static let searchResultsKey = "searchResultsKey"
        static let headerHeight = CGFloat(40)
    }

    enum DataActionType {
        case create
        case remove
        case update
    }
}

// MARK: - Funcs
extension ExerciseDataModel {
    func fetchData() {
        DispatchQueue.main.async { [weak self] in
            self?.dataFetchDelegate?.didBeginFetch()
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            if self.realm?.objects(ExercisesList.self).first == nil {
                let fileName = "all_workouts"
                let fileType = "txt"
                guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType),
                    let content = try? String(contentsOfFile: filePath) else {
                        fatalError("Error while opening file: \(fileName).\(fileType).")
                }

                let exercises = content.components(separatedBy: "\n")
                // Need these copies so realm isn't accessed on the wrong thread
                var realmCopyExercises = List<Exercise>()
                var realmCopySectionTitles = List<String>()

                self.readExercises(exercises: exercises,
                                   realmCopyExercises: &realmCopyExercises,
                                   realmCopySectionTitles: &realmCopySectionTitles)

                let exercisesList = ExercisesList()
                exercisesList.exercises = realmCopyExercises
                exercisesList.sectionTitles = realmCopySectionTitles
                try? self.realm?.write {
                    self.realm?.add(exercisesList)
                }
            }

            DispatchQueue.main.async {
                self.dataFetchDelegate?.didEndFetch()
            }
        }
    }

    private func readExercises(exercises: [String],
                               realmCopyExercises: inout List<Exercise>,
                               realmCopySectionTitles: inout List<String>) {
        // Prevents reading the empty line at EOF
        for exercise in exercises where !exercise.isEmpty {
            let exerciseSplitList = exercise.split(separator: ":")
            let name = String(exerciseSplitList[0])
            let groups =  String(exerciseSplitList[1])

            let newExercise = createExerciseFromStorage(name: name, groups: groups)
            let realmCopyExercise = Exercise(name: newExercise.name,
                                             groups: newExercise.groups,
                                             instructions: newExercise.instructions,
                                             tips: newExercise.tips,
                                             imageNames: newExercise.imageNames,
                                             isUserMade: newExercise.isUserMade,
                                             weightType: newExercise.weightType,
                                             sets: newExercise.sets,
                                             exerciseDetails: newExercise.exerciseDetails)
            realmCopyExercises.append(realmCopyExercise)

            if let title = getFirstCharacter(of: name)?.capitalized,
                !realmCopySectionTitles.contains(title) {
                realmCopySectionTitles.append(title)
            }
        }
    }

    private func createExerciseFromStorage(name: String, groups: String) -> Exercise {
        let lowercased = name.lowercased().replacingOccurrences(of: "/", with: "_")

        // Getting path of resources for app
        guard let resourcePath = Directory.exercises.url?.path else {
            fatalError("Couldn't get main resource path")
        }

        // Creating exercise name folder path
        let exerciseFolderPath = URL(fileURLWithPath: resourcePath)
            .appendingPathComponent(lowercased).path
        guard let contents = try? FileManager().contentsOfDirectory(atPath: exerciseFolderPath) else {
            fatalError("Couldn't get contents for exercise: \(name)")
        }

        var imageNames = List<String>()
        var instructions = "No instructions"
        var tips = "No tips"
        // Contents contains all the file names in the exercise name folder
        contents.forEach {
            if $0.contains(".txt") {
                // Creating a file path for each file name in the exercise name folder
                // Ex: /ab roller crunch/ab roller crunch_0.png
                // Ex: /ab roller crunch/ab roller crunch_1.jpg
                let contentFilePath = URL(fileURLWithPath: exerciseFolderPath)
                    .appendingPathComponent($0).path

                // Getting the data from that file
                guard let data = FileManager().contents(atPath: contentFilePath) else {
                    fatalError("Couldn't get data for exercise: \(name)")
                }

                // Getting raw text array by separating all text by new line character
                let rawText = (String(data: data, encoding: .utf8) ?? "").components(separatedBy: "\n")
                let formattedText = format(text: rawText)

                if $0.contains("info.txt") {
                    instructions = formattedText
                } else if $0.contains("tips.txt") {
                    tips = formattedText
                }
            // Storing image file names first so it can be sorted after
            } else if $0.contains(".png") || $0.contains(".jpg") {
                imageNames.append($0)
            }
        }

        imageNames.sort()

        return Exercise(name: name,
                        groups: groups,
                        instructions: instructions,
                        tips: tips,
                        imageNames: imageNames)
    }

    private func format(text: [String]) -> String {
        // Looping through raw text to add 2 new line vertical spacing between each line of text
        // Ignoring the last line that's empty
        var formattedText = ""
        for (index, line) in text.enumerated() where !line.isEmpty {
            // The last line should only get 1 new line vertical spacing
            let newLine = index < text.count - 2 ? "\n\n" : "\n"
            formattedText.append("\(line)\(newLine)")
        }
        return formattedText
    }

    private func getFirstCharacter(of text: String) -> String? {
        guard let firstCharacter = text.first else {
            return nil
        }
        return String(firstCharacter)
    }

    private func getCorrectExerciseArrayIn(section: Int) -> [Exercise]? {
        guard section > -1,
            section < sectionTitles.count else {
                fatalError("Section: \(section) out of bounds")
        }

        let key: String
        if searchResults.isEmpty {
            key = sectionTitles[section]
        } else {
            key = searchResults
        }

        return exercises.filter {
            return $0.name?.lowercased().hasPrefix(key.lowercased()) ?? false
        }
    }

    private func updateSectionTitles(with exerciseName: String,
                                     action: DataActionType) {
        guard let title = getFirstCharacter(of: exerciseName) else {
            fatalError("Couldn't update section title with \(exerciseName)")
        }

        switch action {
        case .create:
            createSectionTitle(from: title)
        case .remove:
            removeSectionTitle(from: title)
        default:
            break
        }

        let sectionTitlesList = List<String>()
        sectionTitlesList.append(objectsIn: sectionTitles)
        updateSectionTitlesInRealm(titles: sectionTitlesList)
    }

    private func createSectionTitle(from title: String) {
        if !sectionTitles.contains(title) {
            try? realm?.write {
                self.realm?.objects(ExercisesList.self).first?.sectionTitles.append(title)
                self.realm?.objects(ExercisesList.self).first?.sectionTitles.sort()
            }
        }
    }

    private func removeSectionTitle(from title: String) {
        let filteredExercises = exercises.filter {
            $0.name?.hasPrefix(title) ?? false
        }

        if filteredExercises.isEmpty,
           let index = sectionTitles.firstIndex(of: title) {
            try? realm?.write {
                self.realm?.objects(ExercisesList.self).first?.sectionTitles.remove(at: index)
            }
        }
    }

    private func updateSectionTitlesInRealm(titles: List<String>) {
        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.sectionTitles = titles
        }
    }

    // MARK: - UITableView

    var numberOfSections: Int {
        searchResults.isEmpty ? exercises.isEmpty ? 0 : sectionTitles.count : 1
    }

    func numberOfRows(in section: Int) -> Int {
        guard let exerciseArray = getCorrectExerciseArrayIn(section: section) else {
            fatalError("No exercises for section: \(section)")
        }
        return exerciseArray.count
    }

    func heightForHeaderIn(section: Int) -> CGFloat {
        searchResults.isEmpty ? numberOfSections == 0 ? 0 : Constants.headerHeight : 0
    }

    func titleForHeaderIn(section: Int) -> String {
        sectionTitles[section]
    }

    // MARK: - Data

    func doesExerciseExist(name: String) -> Bool {
        exercises.contains(where: { (exercise) -> Bool in
            exercise.name == name
        })
    }

    func exercise(for name: String) -> Exercise {
        guard let exercise = exercises.first(where: { (exercise) -> Bool in
            exercise.name == name
        }) else {
            fatalError("\(name) does not exist")
        }
        return exercise
    }

    func exercise(for indexPath: IndexPath) -> Exercise {
        guard let exerciseArray = getCorrectExerciseArrayIn(section: indexPath.section) else {
            fatalError("No exercises for section: \(indexPath.section)")
        }

        guard indexPath.row > -1,
            indexPath.row < exerciseArray.count else {
                fatalError("Index: \(indexPath.section) out of bounds")
        }
        return exerciseArray[indexPath.row]
    }

    var defaultExerciseGroupCount: Int {
        exerciseGroups.count
    }

    var defaultExerciseGroups: [String] {
        exerciseGroups
    }

    func defaultExerciseGroup(for index: Int) -> String {
        guard index < exerciseGroups.count else {
            return ""
        }
        return exerciseGroups[index]
    }

    func filterResults(filter: String) {
        guard !filter.isEmpty else {
            searchResults.removeAll()
            return
        }

        searchResults = filter
    }

    func index(of name: String) -> Int? {
        exercises.firstIndex(where: {
            name == $0.name
        })
    }

    func removeSearchedResults() {
        searchResults.removeAll()
    }

    func create(_ exercise: Exercise, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        let name = exercise.name ?? ""

        guard !doesExerciseExist(name: name) else {
            fail?()
            return
        }

        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.exercises.append(exercise)
            realm?.objects(ExercisesList.self).first?.exercises.sort()
        }

        updateSectionTitles(with: name, action: .create)
        success?()
    }

    func update(_ currentName: String,
                exercise: Exercise,
                success: (() -> Void)? = nil,
                fail: (() -> Void)? = nil) {
        guard let newName = exercise.name,
            let index = index(of: currentName) else {
            fail?()
            return
        }

        if currentName == newName {
            updateSearchResultsWithExercise(name: newName, newExercise: exercise, action: .update)

            try? realm?.write {
                realm?.objects(ExercisesList.self).first?.exercises[index] = exercise
                success?()
            }
        } else {
            guard !doesExerciseExist(name: newName) else {
                fail?()
                return
            }

            updateSearchResultsWithExercise(name: currentName, action: .remove)
            updateSearchResultsWithExercise(newExercise: exercise, action: .create)

            try? realm?.write {
                realm?.objects(ExercisesList.self).first?.exercises.remove(at: index)
                realm?.objects(ExercisesList.self).first?.exercises.append(exercise)
                realm?.objects(ExercisesList.self).first?.exercises.sort()
            }

            updateSectionTitles(with: newName, action: .create)
            updateSectionTitles(with: currentName, action: .remove)
            success?()
        }
    }

    func removeExercise(named: String?) {
        guard let name = named,
            let index = index(of: name) else {
            return
        }

        updateSearchResultsWithExercise(name: name, action: .remove)

        let exercise = exercises[index]
        Utility.removeImages(names: Array(exercise.imageNames))

        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.exercises.remove(at: index)
        }

        updateSectionTitles(with: name, action: .remove)
    }

    private func updateSearchResultsWithExercise(name: String = "",
                                                 newExercise: Exercise = Exercise(),
                                                 action: DataActionType) {
        guard !searchResults.isEmpty else {
            return
        }

        switch action {
        case .create:
            try? realm?.write {
                realm?.objects(ExercisesList.self).first?.exercises.append(newExercise)
                realm?.objects(ExercisesList.self).first?.exercises.sort()
            }
        case .remove, .update:
            guard let firstIndex = exercises.firstIndex(where: { (exercise) -> Bool in
                exercise.name == name
            }) else {
                return
            }

            if action == .remove {
                try? realm?.write {
                    realm?.objects(ExercisesList.self).first?.exercises.remove(at: firstIndex)
                }
            } else if action == .update {
                try? realm?.write {
                    realm?.objects(ExercisesList.self).first?.exercises[firstIndex] = newExercise
                }
            }
        }
    }
}
