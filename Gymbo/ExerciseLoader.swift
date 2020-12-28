//
//  ExerciseLoader.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/27/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class ExerciseLoader {
    static var shared = ExerciseLoader()

    var realm: Realm? {
        try? Realm()
    }

    let exerciseGroups = ["Abs", "Arms", "Back",
                          "Chest", "Glutes", "Hips",
                          "Legs", "Other", "Shoulders"]
}

// MARK: - Structs/Enums
private extension ExerciseLoader {
}

// MARK: - Funcs
extension ExerciseLoader {
    func loadExercises(completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }

            if self.realm?.objects(ExercisesList.self).first == nil {
                let filename = "all_workouts"
                let fileType = "txt"
                guard let filePath = Bundle.main.path(forResource: filename, ofType: fileType),
                    let content = try? String(contentsOfFile: filePath) else {
                        fatalError("Error while opening file: \(filename).\(fileType).")
                }

                let exercises = content.components(separatedBy: "\n")
                // Need these copies so realm isn't accessed on the wrong thread
                var realmCopyExercises = List<Exercise>()
                let realmCopySectionTitles = List<String>()
                let sections = self.readSections()
                realmCopySectionTitles.append(objectsIn: sections)

                self.readExercises(exercises: exercises,
                                   realmCopyExercises: &realmCopyExercises)

                let exercisesList = ExercisesList()
                exercisesList.exercises.append(objectsIn: realmCopyExercises)
                exercisesList.sectionTitles.append(objectsIn: realmCopySectionTitles)
                try? self.realm?.write {
                    self.realm?.add(exercisesList)
                }
            }
            completion?()
        }
    }

    private func readSections() -> [String] {
        let sectionsFilename = "exercise_sections"
        let fileType = "txt"
        guard let filePath = Bundle.main.path(forResource: sectionsFilename, ofType: fileType),
              var content = try? String(contentsOfFile: filePath)
                .components(separatedBy: "\n") else {
                fatalError("Error while opening file: \(sectionsFilename).\(fileType).")
        }

        // Removing last empty line
        content.removeLast()
        return content
    }

    private func readExercises(exercises: [String],
                               realmCopyExercises: inout List<Exercise>) {
        // Prevents reading the empty line at EOF
        for exercise in exercises where !exercise.isEmpty {
            let exerciseSplitList = exercise.split(separator: ":")
            let name = String(exerciseSplitList[0])
            let groups =  String(exerciseSplitList[1])

            let newExercise = createExerciseFromStorage(name: name, groups: groups)
            let realmCopyExercise = newExercise.safeCopy
            realmCopyExercises.append(realmCopyExercise)
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
}
