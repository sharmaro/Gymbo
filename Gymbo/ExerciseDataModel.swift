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
                                  "Glutes", "Hips", "Legs", "Other", "Shoulders"]

    private var isFirstTimeLoad = true
    private var firstTimeLoadExercises = List<Exercise>()

    private var exercises: [Exercise] {
        isFirstTimeLoad ?
        Array(firstTimeLoadExercises) :
        Array(realm?.objects(ExercisesList.self).first?.exercises ?? List<Exercise>())
    }

    // Used to store the filtered results based on user search
    private var searchResults = ""
    private(set) var sectionTitles = [String]()

    weak var dataFetchDelegate: DataFetchDelegate?
}

// MARK: - Structs/Enums
private extension ExerciseDataModel {
    struct Constants {
        static let searchResultsKey = "searchResultsKey"
    }

    enum SearchResultsAction {
        case create
        case remove
        case update
    }
}

// MARK: - Funcs
extension ExerciseDataModel {
    // MARK: - Helper

    func fetchData() {
        DispatchQueue.main.async { [weak self] in
            self?.dataFetchDelegate?.didBeginFetch()
        }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            if self.realm?.objects(ExercisesList.self).first != nil {
                self.isFirstTimeLoad = false
                self.sectionTitles =
                    Array(self.realm?.objects(ExercisesList.self).first?.sectionTitles ?? List<String>())

                DispatchQueue.main.async {
                    self.dataFetchDelegate?.didEndFetch()
                }
            } else {
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

                DispatchQueue.main.async {
                    self.dataFetchDelegate?.didEndFetch()
                }

                let exercisesList = ExercisesList()
                exercisesList.exercises = realmCopyExercises
                exercisesList.sectionTitles = realmCopySectionTitles
                try? self.realm?.write {
                    self.realm?.add(exercisesList)
                }
                self.isFirstTimeLoad = false

                /*
                 Updating realm again in case the user adds
                 any exercises while the original exercises
                 array is still being written to realm
                 */
                DispatchQueue.main.async {
                    let updatedExercisesList = List<Exercise>()
                    updatedExercisesList.append(objectsIn: self.exercises)
                    try? self.realm?.write {
                        self.realm?.objects(ExercisesList.self).first?.exercises = updatedExercisesList
                    }
                }
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

            let newExercise = self.createExerciseFromStorage(name: name, groups: groups)
            let realmCopyExercise = Exercise(name: newExercise.name,
                                             groups: newExercise.groups,
                                             instructions: newExercise.instructions,
                                             tips: newExercise.tips,
                                             imagesData: newExercise.imagesData,
                                             isUserMade: newExercise.isUserMade,
                                             weightType: newExercise.weightType,
                                             sets: newExercise.sets,
                                             exerciseDetails: newExercise.exerciseDetails)
            self.firstTimeLoadExercises.append(newExercise)
            realmCopyExercises.append(realmCopyExercise)

            if let title = self.getFirstCharacter(of: name)?.capitalized,
                !self.sectionTitles.contains(title) {
                self.sectionTitles.append(title)
                realmCopySectionTitles.append(title)
            }
        }
    }

    //swiftlint:disable:next cyclomatic_complexity
    private func createExerciseFromStorage(name: String, groups: String) -> Exercise {
        let lowercased = name.lowercased().replacingOccurrences(of: "/", with: "_")
        let exerciseFolderPathString = "Workout Info/\(lowercased)"

        // Getting path of resources for app
        guard let resourcePath = Bundle.main.resourcePath else {
            fatalError("Couldn't get resource path for exercise: \(name)")
        }

        // Creating exercise name folder path
        //swiftlint:disable:next line_length
        let exerciseFolderPath = URL(fileURLWithPath: resourcePath).appendingPathComponent(exerciseFolderPathString).path
        guard let contents = try? FileManager().contentsOfDirectory(atPath: exerciseFolderPath) else {
            fatalError("Couldn't get contents for exercise: \(name)")
        }

        var imageFileNames = [String]()
        var instructions = "No instructions"
        var tips = "No tips"
        // Contents contains all the file names in the exercise name folder
        for content in contents {
            if content.contains(".txt") {
                // Creating a file path for each file name in the exercise name folder
                // ex: /ab roller crunch/ab roller crunch_0.png
                //swiftlint:disable:next line_length
                let contentFilePath = URL(fileURLWithPath: exerciseFolderPath).appendingPathComponent(content).path

                // Getting the data from that file
                guard let data = FileManager().contents(atPath: contentFilePath) else {
                    fatalError("Couldn't get text data for exercise: \(name)")
                }

                // Getting raw text array by separating all text by new line character
                let rawText = (String(data: data, encoding: .utf8) ?? "").components(separatedBy: "\n")
                var formattedText = ""
                // Looping through raw text to add 2 new line vertical spacing between each line of text
                // Ignoring the last line that's empty
                for (index, line) in rawText.enumerated() where !line.isEmpty {
                    // The last line should only get 1 new line vertical spacing
                    if index < rawText.count - 2 {
                        formattedText.append("\(line)\n\n")
                    } else {
                        formattedText.append("\(line)\n")
                    }
                }

                if content.contains("info.txt") {
                    instructions = formattedText
                } else if content.contains("tips.txt") {
                    tips = formattedText
                }
            // Storing image file names first so it can be sorted after
            } else if content.contains(".png") || content.contains(".jpg") {
                imageFileNames.append(content)
            }
        }

        imageFileNames.sort()
        let imagesData = List<Data>()
        // Getting image data and appending it to imagesData array
        // Can't store data as [UIImage] because [UIImage] doesn't conform to Codable
        for imageName in imageFileNames {
            //swiftlint:disable:next line_length
            let contentFilePath = URL(fileURLWithPath: exerciseFolderPath).appendingPathComponent(imageName).path

            guard let data = FileManager().contents(atPath: contentFilePath) else {
                fatalError("Couldn't get image data for exercise: \(name)")
            }

            imagesData.append(data)
        }

        return Exercise(name: name,
                        groups: groups,
                        instructions: instructions,
                        tips: tips,
                        imagesData: imagesData)
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
        numberOfSections == 1 ? 0 : 40
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

    func defaultExerciseGroupCount() -> Int {
        exerciseGroups.count
    }

    func defaultExerciseGroups() -> [String] {
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

        DispatchQueue.main.async {
            try? self.realm?.write {
                self.realm?.objects(ExercisesList.self).first?.exercises.append(exercise)
                self.realm?.objects(ExercisesList.self).first?.exercises.sort()
                success?()
            }
        }
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
                success?()
            }
        }
    }

    func removeExercise(named: String?) {
        guard let name = named,
            let index = index(of: name) else {
            return
        }

        updateSearchResultsWithExercise(name: name, action: .remove)

        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.exercises.remove(at: index)
        }
    }

    private func updateSearchResultsWithExercise(name: String = "",
                                                 newExercise: Exercise = Exercise(),
                                                 action: SearchResultsAction) {
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
