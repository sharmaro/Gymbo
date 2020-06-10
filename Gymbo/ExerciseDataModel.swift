//
//  ExerciseDataModelManager.swift
//  Gymbo
//
//  Created by Rohan Sharma on 2/3/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
@objcMembers class ExercisesInfoList: Object {
    var exercises = List<ExerciseInfo>()
}

// MARK: - Properties
@objcMembers class ExerciseInfo: Object, Comparable {
    dynamic var name: String?
    dynamic var muscles: String?
    dynamic var groups: String?
    dynamic var instructions: String?
    dynamic var tips: String?
    let imagesData = List<Data>()
    dynamic var isUserMade = false

    convenience init(name: String?, muscles: String?, groups: String?, instructions: String? = nil, tips: String? = nil, imagesData: List<Data> = List<Data>(), isUserMade: Bool = false) {
        self.init()

        self.name = name
        self.muscles = muscles
        self.groups = groups
        self.instructions = instructions
        self.tips = tips
        for imageData in imagesData {
            self.imagesData.append(imageData)
        }
        self.isUserMade = isUserMade
    }

    static func < (lhs: ExerciseInfo, rhs: ExerciseInfo) -> Bool {
        guard let lhsName = lhs.name,
            let rhsName = rhs.name else {
            return false
        }
        return lhsName < rhsName
    }
}

// MARK: - Properties
class ExerciseDataModel: NSObject {
    static let shared = ExerciseDataModel()

    private let exerciseGroups = ["Abs", "Arms", "Back", "Chest", "Glutes", "Hips", "Legs", "Shoulders", "Extra Exercises"]
    private var realm = try? Realm()
    private var exercisesInfoList = ExercisesInfoList()
    // Helper for getting exercises as an array
    private var exercisesInfoArray: [ExerciseInfo] {
        return Array(exercisesInfoList.exercises)
    }
    private var exercisesInfoListCache = [String: ExerciseInfo]()
    // Used to store the filtered results based on user search
    var searchResults = [ExerciseInfo]()

    var dataToUse: [ExerciseInfo] {
        return searchResults.count > 0 ? searchResults : exercisesInfoArray
    }

    override init() {
        super.init()

        setupExerciseInfoList()
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
    private func setupExerciseInfoList() {
        if let exercisesInfoList = realm?.objects(ExercisesInfoList.self).first {
            self.exercisesInfoList = exercisesInfoList

            // Keeping a dictionary cache for fast lookups
            exercisesInfoArray.forEach {
                let name = $0.name ?? ""
                exercisesInfoListCache[name] = $0
            }
        } else {
            for group in exerciseGroups {
                guard let filePath = Bundle.main.path(forResource: group, ofType: "txt"),
                    let content = try? String(contentsOfFile: filePath) else {
                        fatalError("Error while opening file: \(group).txt.")
                }

                let exercises = content.components(separatedBy: "\n")
                for exercise in exercises {
                    // Prevents reading the empty line at EOF
                    if exercise.count > 0 {
                        let exerciseSplitList = exercise.split(separator: ":")
                        let name = String(exerciseSplitList[0])
                        let muscles =  String(exerciseSplitList[1])

                        if let existingExerciseInfoObject = exercisesInfoListCache[name] {
                            if var groups = existingExerciseInfoObject.groups {
                                groups.append(",\(group)")
                                existingExerciseInfoObject.groups = groups
                            } else {
                                existingExerciseInfoObject.groups = ("\(group)")
                            }
                            exercisesInfoListCache[name] = existingExerciseInfoObject
                        }

                        let newExerciseInfo = createExerciseObject(name: name, muscles: muscles, group: group)
                        exercisesInfoListCache[name] = newExerciseInfo
                    }
                }
            }
            exercisesInfoListCache.forEach {
                let info = $0.value
                exercisesInfoList.exercises.append(info)
            }
            exercisesInfoList.exercises.sort()
            try? realm?.write {
                realm?.add(exercisesInfoList)
            }
        }
    }

    private func createExerciseObject(name: String, muscles: String, group: String) -> ExerciseInfo {
        let lowercased = name.lowercased().replacingOccurrences(of: "/", with: "_")
        let exerciseInfoFolderPathString = "Workout Info/\(lowercased)"

        // Getting path of resources for app
        guard let resourcePath = Bundle.main.resourcePath else {
            fatalError("Couldn't get resource path for exercise: \(name)")
        }

        // Creating exercise name folder path
        let exerciseInfoFolderPath = URL(fileURLWithPath: resourcePath).appendingPathComponent(exerciseInfoFolderPathString).path
        guard let contents = try? FileManager().contentsOfDirectory(atPath: exerciseInfoFolderPath) else {
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
                let contentFilePath = URL(fileURLWithPath: exerciseInfoFolderPath).appendingPathComponent(content).path

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
                    if line.count > 0 {
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
            let contentFilePath = URL(fileURLWithPath: exerciseInfoFolderPath).appendingPathComponent(imageName).path

            guard let data = FileManager().contents(atPath: contentFilePath) else{
                fatalError("Couldn't get image data for exercise: \(name)")
            }

            imagesData.append(data)
        }

        return ExerciseInfo(name: name, muscles: muscles, groups: group, instructions: instructions, tips: tips, imagesData: imagesData)
    }

    func numberOfRows(in section: Int) -> Int {
        return dataToUse.count
    }

    func index(of exerciseName: String) -> Int? {
        guard exercisesInfoListCache[exerciseName] != nil,
            let index = dataToUse.firstIndex(where: {
                ($0.name ?? "") == exerciseName
            }) else {
            return nil
        }
        return index
    }

    func exerciseInfo(for row: Int) -> ExerciseInfo {
        return dataToUse[row]
    }

    func exerciseInfoList(for session: Session) -> [ExerciseInfo] {
        var infoList = [ExerciseInfo]()
        session.exercises.forEach {
            if let exerciseName = $0.name, let exerciseInfo = exercisesInfoListCache[exerciseName] {
                infoList.append(exerciseInfo)
            }
        }
        return infoList
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

    func exerciseGroups(for index: Int) -> String? {
        return dataToUse[index].groups
    }

    func filterResults(filter: String) {
        searchResults = exercisesInfoArray.filter {
            ($0.name ?? "").lowercased().contains(filter)
        }
    }

    func removeSearchedResults() {
        searchResults.removeAll()
    }

    func createExerciseInfo(_ info: ExerciseInfo, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        let name = info.name ?? ""

        guard exercisesInfoListCache[name] == nil else {
            fail?()
            return
        }

        exercisesInfoListCache[name] = info
        try? realm?.write {
            exercisesInfoList.exercises.append(info)
            exercisesInfoList.exercises.sort()
            success?()
        }
    }

    func updateExerciseInfo(_ currentName: String, info: ExerciseInfo, success: (() -> Void)? = nil, fail: (() -> Void)? = nil) {
        guard let newName = info.name,
            let currentExerciseInfo = exercisesInfoListCache[currentName] else {
            fail?()
            return
        }

        let index = exercisesInfoList.exercises.firstIndex { (info) -> Bool in
            currentExerciseInfo.name == currentName
        }
        guard let indexToInteractAt = index else {
            fail?()
            return
        }

        exercisesInfoListCache[newName] = info

        if currentName == newName {
            try? realm?.write {
                exercisesInfoList.exercises[indexToInteractAt] = info
                success?()
            }
        } else {
            exercisesInfoListCache[currentName] = nil

            try? realm?.write {
                exercisesInfoList.exercises.remove(at: indexToInteractAt)
                exercisesInfoList.exercises.append(info)
                exercisesInfoList.exercises.sort()
                success?()
            }
        }
    }

    func removeExercise(at index: Int) {
        guard index < exercisesInfoArray.count,
            let name = exercisesInfoArray[index].name else {
                return
        }

        exercisesInfoListCache[name] = nil
        try? realm?.write {
            exercisesInfoList.exercises.remove(at: index)
        }
    }
}
