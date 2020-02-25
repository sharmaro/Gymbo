//
//  ExerciseDataModelManager.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import Foundation

class ExerciseDataModel: NSObject {
    // MARK: - Parameters
    static let shared = ExerciseDataModel()

    private let exerciseGroups = ["Abs", "Arms", "Back", "Buttocks", "Chest",
    "Hips", "Legs", "Shoulders", "Extra Exercises"]
    var exerciseData = [String: [ExerciseText]]()
    // Used to store the filtered results based on user search
    var searchResults = [String: [ExerciseText]]()

    override init() {
        super.init()

        setupExerciseInfo()
    }
}

// MARK: - Structs/Enums
private extension ExerciseDataModel {
    struct Constants {
        static let EXERCISE_INFO_KEY = "exerciseInfoKey"
    }
}

// MARK: - Funcs
extension ExerciseDataModel {
    private func setupExerciseInfo() {
        if let exerciseDict = loadExerciseInfo() {
            exerciseData = exerciseDict
        } else {
            for group in exerciseGroups {
                do {
                    guard let filePath = Bundle.main.path(forResource: group, ofType: "txt"),
                        let content = try? String(contentsOfFile: filePath) else {
                            fatalError("Error while opening file: \(group).txt.")
                    }
                    let exercises = content.components(separatedBy: "\n")
                    for exercise in exercises {
                        // Prevents reading the empty line at EOF
                        if exercise.count > 0 {
                            let exerciseSplitList = exercise.split(separator: ":")
                            let exerciseName = String(exerciseSplitList[0])
                            let exerciseMuscles =  String(exerciseSplitList[1])
                            let exerciseText = ExerciseText(exerciseName: exerciseName,
                                                            exerciseMuscles: exerciseMuscles,
                                                            isUserMade: false)
                            if exerciseData[group] == nil {
                                exerciseData[group] = [exerciseText]
                            } else {
                                exerciseData[group]?.append(exerciseText)
                            }
                        }
                    }
                }
            }
        }
    }

    private func loadExerciseInfo() -> [String: [ExerciseText]]? {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        guard let data = defaults.data(forKey: Constants.EXERCISE_INFO_KEY),
            let exerciseDict = try? decoder.decode(Dictionary<String, [ExerciseText]>.self, from: data) else {
            return nil
        }
        return exerciseDict
    }

    private func saveExercises() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode(exerciseData) {
            defaults.set(encodedData, forKey: Constants.EXERCISE_INFO_KEY)
        }
    }

    private func dataToUse() -> [String: [ExerciseText]] {
        return searchResults.count > 0 ? searchResults : exerciseData
    }

    func numberOfSections() -> Int {
        guard exerciseData.count > 0 else {
            fatalError("exerciseData.count <= 0")
        }
        return exerciseData.count
    }

    func numberOfRows(in section: Int) -> Int {
        guard let exerciseGroup = exerciseGroup(for: section) else {
            fatalError("Exercise group for section \(section) is nil")
        }

        if searchResults.count > 0, let count = searchResults[exerciseGroup]?.count {
            return count
        }

        guard let count = exerciseData[exerciseGroup]?.count else {
            fatalError("exerciseData[exerciseGroup]?.count is nil")
        }
        return count
    }

    func indexPath(from section: Int, exerciseName name: String) -> IndexPath? {
        guard section > -1,
            section < exerciseGroups.count else {
            return nil
        }
        let exerciseGroup = exerciseGroups[section]
        if let exercises = exerciseData[exerciseGroup] {
            for (index, value) in exercises.enumerated() {
                if let exerciseName = value.exerciseName,
                    exerciseName == name {
                    return IndexPath(row: index, section: section)
                }
            }
        }
        return nil
    }

    func exerciseTableViewCellModel(for group: String, for row: Int) -> ExerciseText {
        let data = dataToUse()
        guard let exerciseText = data[group],
            row < exerciseText.count else {
            fatalError("Exercise text for group \(group) is nil")
        }

        return exerciseText[row]
    }

    func exerciseGroup(for index: Int) -> String? {
        guard index > -1,
            index < exerciseGroups.count else {
            return nil
        }

        return exerciseGroups[index]
    }

    func exerciseText(for group: String, for row: Int) -> ExerciseText {
        guard let exerciseTexts = exerciseData[group], row < exerciseTexts.count else {
            fatalError("Exercise text for group \(group) is nil")
        }
        return exerciseTexts[row]
    }

    func filterResults(filter: String) {
        exerciseData.forEach {
            searchResults[$0.key] = $0.value.filter {
                ($0.exerciseName ?? "").lowercased().contains(filter)
            }
        }
    }

    func removeSearchedResults() {
        searchResults.removeAll()
    }

    func addCreatedExercise(exerciseGroup: String, exerciseText: ExerciseText) {
        if exerciseData[exerciseGroup] == nil {
            exerciseData[exerciseGroup] = [exerciseText]
        } else {
            exerciseData[exerciseGroup]?.append(exerciseText)
            exerciseData[exerciseGroup]?.sort {
                return ($0.exerciseName ?? "").lowercased() < ($1.exerciseName ?? "").lowercased()
            }
        }
        saveExercises()
    }

    func removeExercise(at indexPath: IndexPath) {
        guard indexPath.section < exerciseGroups.count,
            let exercisesCount = exerciseData[exerciseGroups[indexPath.section]]?.count,
            indexPath.row < exercisesCount else {
                return
        }
        let group = exerciseGroups[indexPath.section]
        var exercises = exerciseData[group] ?? [ExerciseText]()
        exercises.remove(at: indexPath.row)
        exerciseData[group] = exercises

        saveExercises()
    }
}
