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
    static let shared = ExerciseDataModel()

    private var realm = try? Realm()
    private var exercisesList = ExercisesList()

    private let exerciseGroups = ["Abs", "Arms", "Back", "Chest",
                                  "Glutes", "Hips", "Legs", "Other", "Shoulders"]
    // Stores exercises based on their first character
    private var exercisesDictionary = [String: [Exercise]]()
    // Stores exercises by name for quick lookup
    private var exercisesCache = [String: Exercise]()
    // Used to store the filtered results based on user search
    private var searchResults = [String: [Exercise]]()

    private(set) var sectionTitles = [String]()

    private var dataToUse: [String: [Exercise]] {
        return searchResults.isEmpty ? exercisesDictionary : searchResults
    }

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

    func fetchExercises() {
        if let exercisesList = realm?.objects(ExercisesList.self).first {
            self.exercisesList = exercisesList

            dataFetchDelegate?.didBeginFetch()
            DispatchQueue.global(qos: .background).async { [weak self] in
                // Realm objects can only be used on the thread that creates them
                let backgroundRealm = try? Realm()
                if let backgroundExercisesList = backgroundRealm?.objects(ExercisesList.self).first {
                    self?.setupExercisesDictionary(exercisesList: backgroundExercisesList)
                }
            }
        } else {
            dataFetchDelegate?.didBeginFetch()
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }

                for group in self.exerciseGroups {
                    guard let filePath = Bundle.main.path(forResource: group, ofType: "txt"),
                        let content = try? String(contentsOfFile: filePath) else {
                            fatalError("Error while opening file: \(group).txt.")
                    }

                    let exercises = content.components(separatedBy: "\n")
                    for exercise in exercises {
                        // Prevents reading the empty line at EOF
                        if !exercise.isEmpty {
                            let exerciseSplitList = exercise.split(separator: ":")
                            let name = String(exerciseSplitList[0])
                            let groups =  String(exerciseSplitList[1])

                            // Skip adding existing exercises
                            if self.exercisesCache[name] != nil {
                                continue
                            }

                            let newExercise = self.createExerciseFromStorage(name: name, groups: groups)
                            self.exercisesCache[name] = newExercise
                            self.exercisesList.exercises.append(newExercise)

                            if let title = self.getFirstCharacter(of: name)?.capitalized {
                                if var exercisesArray = self.exercisesDictionary[title] {
                                    exercisesArray.append(newExercise)
                                    self.exercisesDictionary[title] = exercisesArray
                                } else {
                                    self.exercisesDictionary[title] = [newExercise]
                                }

                                if !self.sectionTitles.contains(title) {
                                    self.sectionTitles.append(title)
                                }
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.sectionTitles.sort()
                    self.exercisesList.exercises.sort()

                    try? self.realm?.write {
                        self.realm?.add(self.exercisesList)
                        self.dataFetchDelegate?.didFinishFetch()
                    }
                }
            }
        }
    }

    private func createExerciseFromStorage(name: String, groups: String) -> Exercise {
        let lowercased = name.lowercased().replacingOccurrences(of: "/", with: "_")
        let exerciseFolderPathString = "Workout Info/\(lowercased)"

        // Getting path of resources for app
        guard let resourcePath = Bundle.main.resourcePath else {
            fatalError("Couldn't get resource path for exercise: \(name)")
        }

        // Creating exercise name folder path
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
                let contentFilePath = URL(fileURLWithPath: exerciseFolderPath).appendingPathComponent(content).path

                // Getting the data from that file
                guard let data = FileManager().contents(atPath: contentFilePath) else{
                    fatalError("Couldn't get text data for exercise: \(name)")
                }

                // Getting raw text array by separating all text by new line character
                let rawText = (String(data: data, encoding: .utf8) ?? "").components(separatedBy: "\n")
                var formattedText = ""
                // Looping through raw text to add 2 new line vertical spacing between each line of text
                for (index, line) in rawText.enumerated() {
                    // Ignoring the last line that's empty
                    if !line.isEmpty {
                        // The last line should only get 1 new line vertical spacing
                        if index < rawText.count - 2 {
                            formattedText.append("\(line)\n\n")
                        } else {
                            formattedText.append("\(line)\n")
                        }
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
            let contentFilePath = URL(fileURLWithPath: exerciseFolderPath).appendingPathComponent(imageName).path

            guard let data = FileManager().contents(atPath: contentFilePath) else{
                fatalError("Couldn't get image data for exercise: \(name)")
            }

            imagesData.append(data)
        }

        return Exercise(name: name, groups: groups, instructions: instructions, tips: tips, imagesData: imagesData)
    }

    private func setupExercisesDictionary(exercisesList: ExercisesList) {
        exercisesList.exercises.forEach {
            // ThreadSafeReference allows the passing of Realm objects between threads
            let backgroundThreadExercise = ThreadSafeReference(to: $0)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                if let mainThreadExercise = self.realm?.resolve(backgroundThreadExercise),
                    let name = mainThreadExercise.name,
                    let title = self.getFirstCharacter(of: name)?.capitalized {
                    if var exercisesArray = self.exercisesDictionary[title] {
                        exercisesArray.append(mainThreadExercise)
                        self.exercisesDictionary[title] = exercisesArray
                    } else {
                        self.exercisesDictionary[title] = [mainThreadExercise]
                    }

                    // Keeping a dictionary cache for fast lookups
                    self.exercisesCache[name] = mainThreadExercise

                    if !self.sectionTitles.contains(title) {
                        self.sectionTitles.append(title)
                    }
                }
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.sectionTitles.sort()
            self?.dataFetchDelegate?.didFinishFetch()
        }
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
        if searchResults.count == 0 {
            key = sectionTitles[section]
        } else {
            key = searchResults.keys.first ?? ""
        }
        return dataToUse[key]
    }

    // MARK: - UITableView

    var numberOfSections: Int {
        return dataToUse.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard let exerciseArray = getCorrectExerciseArrayIn(section: section) else {
            fatalError("No exercises for section: \(section)")
        }
        return exerciseArray.count
    }

    func heightForHeaderIn(section: Int) -> CGFloat {
        return dataToUse.count == 1 ? 0 : 40
    }

    func titleForHeaderIn(section: Int) -> String {
        return sectionTitles[section]
    }

    // MARK: - Data

    func doesExerciseExist(name: String) -> Bool {
        return exercisesCache[name] != nil
    }

    func exercise(for name: String) -> Exercise {
        guard let exercise = exercisesCache[name] else {
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

    func exerciseList(for session: Session) -> [Exercise] {
        var exerciseArray = [Exercise]()
        session.exercises.forEach {
            if let exerciseName = $0.name,
                let exercise = exercisesCache[exerciseName] {
                exerciseArray.append(exercise)
            }
        }
        return exerciseArray
    }

    func defaultExerciseGroupCount() -> Int {
        return exerciseGroups.count
    }

    func defaultExerciseGroups() -> [String] {
        return exerciseGroups
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

        searchResults.removeAll()
        searchResults[Constants.searchResultsKey] = Array(exercisesList.exercises).filter { (exercise) -> Bool in
            (exercise.name ?? "").lowercased().contains(filter)
        }
    }

    func index(of name: String) -> Int? {
        return exercisesList.exercises.firstIndex(where: {
            name == $0.name
        })
    }

    func removeSearchedResults() {
        searchResults.removeAll()
    }

    func create(_ exercise: Exercise, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        let name = exercise.name ?? ""

        guard exercisesCache[name] == nil,
            let firstCharacter = getFirstCharacter(of: name)?.capitalized,
            var exerciseArray = exercisesDictionary[firstCharacter] else {
            fail?()
            return
        }

        exercisesCache[name] = exercise
        exerciseArray.append(exercise)
        exerciseArray.sort()
        exercisesDictionary[firstCharacter] = exerciseArray
        try? realm?.write {
            exercisesList.exercises.append(exercise)
            exercisesList.exercises.sort()
            success?()
        }
    }

    func update(_ currentName: String, exercise: Exercise, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        guard let newName = exercise.name,
            let index = index(of: currentName),
            let firstCharacter = getFirstCharacter(of: currentName)?.capitalized,
            var exerciseArray = exercisesDictionary[firstCharacter],
            let firstIndex = exerciseArray.firstIndex(where: { (exercise) -> Bool in
                exercise.name == currentName
            }) else {
            fail?()
            return
        }

        exercisesCache[newName] = exercise

        if currentName == newName {
            exerciseArray[firstIndex] = exercise
            exercisesDictionary[firstCharacter] = exerciseArray

            updateSearchResultsWithExercise(name: newName, newExercise: exercise, action: .update)

            try? realm?.write {
                exercisesList.exercises[index] = exercise
                success?()
            }
        } else {
            guard exercisesCache[newName] == nil else {
                fail?()
                return
            }

            exercisesCache[currentName] = nil

            exerciseArray.remove(at: firstIndex)
            exerciseArray.append(exercise)
            exerciseArray.sort()
            exercisesDictionary[firstCharacter] = exerciseArray

            updateSearchResultsWithExercise(name: currentName, action: .remove)
            updateSearchResultsWithExercise(newExercise: exercise, action: .create)

            try? realm?.write {
                exercisesList.exercises.remove(at: index)
                exercisesList.exercises.append(exercise)
                exercisesList.exercises.sort()
                success?()
            }
        }
    }

    func removeExercise(named: String?) {
        guard let name = named,
            let index = index(of: name),
            let firstCharacter = getFirstCharacter(of: name)?.capitalized,
            var exerciseArray = exercisesDictionary[firstCharacter],
            let firstIndex = exerciseArray.firstIndex(where: { (exercise) -> Bool in
                exercise.name == name
            }) else {
            return
        }

        exercisesCache[name] = nil
        exerciseArray.remove(at: firstIndex)
        exercisesDictionary[firstCharacter] = exerciseArray

        updateSearchResultsWithExercise(name: name, action: .remove)

        try? realm?.write {
            exercisesList.exercises.remove(at: index)
        }
    }

    private func updateSearchResultsWithExercise(name: String = "", newExercise: Exercise = Exercise(), action: SearchResultsAction) {
        guard !searchResults.isEmpty,
            var exerciseArray = searchResults[Constants.searchResultsKey] else {
            return
        }

        switch action {
        case .create:
            exerciseArray.append(newExercise)
            exerciseArray.sort()
        case .remove, .update:
            guard let firstIndex = exerciseArray.firstIndex(where: { (exercise) -> Bool in
                exercise.name == name
            }) else {
                return
            }

            if action == .remove {
                exerciseArray.remove(at: firstIndex)
            } else if action == .update {
                exerciseArray[firstIndex] = newExercise
            }
        }
        searchResults[Constants.searchResultsKey] = exerciseArray
    }
}
