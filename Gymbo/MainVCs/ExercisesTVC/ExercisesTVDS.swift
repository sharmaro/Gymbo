//
//  ExercisesTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class ExercisesTVDS: NSObject {
    var presentationStyle = PresentationStyle.normal
    var selectedExerciseNames = [String]()

    private var sections = [String]()
    private var filteredDictionary = [String: [Exercise]]()
    private var exercisesDictionary = [String: [Exercise]]()

    private var correctDictionary: [String: [Exercise]] {
        filter.isEmpty ? exercisesDictionary : filteredDictionary
    }

    // Used to store the filtered results based on user search
    private var filter = "" {
        didSet {
            guard !filter.isEmpty else {
                filteredDictionary.removeAll()
                return
            }

            let key = filter.firstCharacter ?? ""
            let filteredExercises = exercisesDictionary[key]?.filter {
                $0.name?.lowercased().hasPrefix(filter.lowercased()) ?? false
            } ?? []
            filteredDictionary = [key: filteredExercises]
        }
    }

    private var realm: Realm? {
        try? Realm()
    }

    private var listDataSources: [ListDataSource]?

    init(listDataSource: ListDataSource?) {
        super.init()

        guard let listDataSource = listDataSource else { return }
        self.listDataSources = []
        self.listDataSources?.append(listDataSource)
        loadExercises()
    }
}

// MARK: - Structs/Enums
extension ExercisesTVDS {
    enum UpdateType {
        case create
        case remove
        case replace
    }
}

// MARK: - Funcs
extension ExercisesTVDS {
    private func loadExercises() {
        ExerciseLoader.shared.loadExercises { [weak self] in
            DispatchQueue.main.async {
                self?.updateExercisesProperty()
                self?.updateSectionsProperty()
            }
        }
    }

    private func updateExercisesProperty() {
        guard let exercises = realm?.objects(ExercisesList.self)
                .first?.exercises else {
            return
        }

        let exercisesArray = Array(exercises)
        for exercise in exercisesArray {
            let section = exercise.name?.firstCharacter ?? ""
            add(exercise: exercise, section: section)
        }
    }

    private func updateSectionsProperty() {
        guard let sections = realm?.objects(ExercisesList.self)
                .first?.sectionTitles else {
            return
        }
        self.sections = Array(sections)
    }

    private func updateExerciseDictionary(exercise: Exercise,
                                          updateType: UpdateType) {
        let name = exercise.name ?? ""
        let section = name.firstCharacter ?? ""

        switch updateType {
        case .create:
            add(exercise: exercise, section: section)
        case .remove, .replace:
            guard let exercises = correctDictionary[section],
                  let index = exercises.firstIndex(where: {
                    $0.name == name
                  }) else {
                fatalError("Can't get index of \(name)")
            }

            if updateType == .remove {
                remove(exercises: exercises,
                       index: index,
                       section: section)
            } else {
                replace(exercises: exercises,
                        exercise: exercise,
                        index: index,
                        section: section)
            }
        }
        updateSections()
        guard let listDataSources = listDataSources else {
            return
        }
        /*
         - Only reloading data for the VCs that are not in view
         - The VC in view will automatically update the UI once data changes
         */
        for index in 0 ..< listDataSources.count - 1 {
            let listDataSource = listDataSources[index]
            listDataSource.reloadData()
        }
    }

    private func add(exercise: Exercise,
                     section: String) {
        if var exercises = correctDictionary[section] {
            exercises.append(exercise)
            exercises.sort()
            exercisesDictionary[section] = exercises
        } else {
            exercisesDictionary[section] = [exercise]
        }
    }

    private func remove(exercises: [Exercise],
                        index: Int,
                        section: String) {
        var mutableExercises = exercises
        mutableExercises.remove(at: index)

        if mutableExercises.isEmpty {
            exercisesDictionary[section] = nil
        } else {
            exercisesDictionary[section] = mutableExercises
        }
    }

    private func replace(exercises: [Exercise],
                         exercise: Exercise,
                         index: Int,
                         section: String) {
        var mutableExercises = exercises
        mutableExercises[index] = exercise
        exercisesDictionary[section] = mutableExercises
    }

    private func getCorrectArray(for key: String) -> [Exercise] {
        guard let firstCharacter = key.firstCharacter,
              let array = correctDictionary[firstCharacter] else {
            return []
        }
        return array
    }

    private func getCorrectKey(for section: Int) -> String {
        let defaultKey = sections[section]
        let filteredKey = filter.firstCharacter?.uppercased() ?? ""
        return filter.isEmpty ? defaultKey : filteredKey
    }

    private func updateSections() {
        sections = exercisesDictionary.keys.map { $0 }
        sections.sort()

        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.sectionTitles.removeAll()
            realm?.objects(ExercisesList.self).first?.sectionTitles.append(objectsIn: sections)
        }
    }

    private func doesExerciseExist(name: String) -> Bool {
        getCorrectArray(for: name).contains(where: { (exercise) -> Bool in
            exercise.name == name
        })
    }

    private func handleCellSelectionState(exerciseName: String,
                                          in tableView: UITableView,
                                          indexPath: IndexPath) {
        guard presentationStyle == .modal,
              !selectedExerciseNames.isEmpty else {
            return
        }

        if selectedExerciseNames.contains(exerciseName) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    func removeLastDS() {
        if !(listDataSources?.isEmpty ?? true) {
            listDataSources?.removeLast()
        }
    }

    func prepareForReuse(newListDataSource: ListDataSource?) {
        presentationStyle = .normal
        selectedExerciseNames.removeAll()
        filter.removeAll()

        if let newListDataSource = newListDataSource {
            listDataSources?.append(newListDataSource)
        }
    }

    func selectCell(exerciseName: String?,
                    in tableView: UITableView,
                    indexPath: IndexPath) {
        guard let exerciseName = exerciseName else {
            return
        }

        if selectedExerciseNames.contains(exerciseName) {
            guard let index = selectedExerciseNames.firstIndex(where: {
                $0 == exerciseName
            }) else {
                return
            }
            selectedExerciseNames.remove(at: index)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            selectedExerciseNames.append(exerciseName)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }

    func exercise(for name: String) -> Exercise {
        let exercises = getCorrectArray(for: name)
        guard let exercise = exercises.first(where: { (exercise) -> Bool in
            exercise.name == name
        }) else {
            fatalError("\(name) does not exist")
        }
        return exercise
    }

    func exercise(for indexPath: IndexPath) -> Exercise {
        let key = getCorrectKey(for: indexPath.section)
        let exerciseArray = getCorrectArray(for: key)

        guard indexPath.row > -1,
            indexPath.row < exerciseArray.count else {
                fatalError("Index: \(indexPath.section) out of bounds")
        }
        return exerciseArray[indexPath.row]
    }

    func allExercisesIndex(of name: String) -> Int? {
        let exercises = realm?
                .objects(ExercisesList.self).first?.exercises
        return exercises?.firstIndex(where: {
            name == $0.name
        })
    }

    func create(_ exercise: Exercise, completion: @escaping(Result<Any?, DataError>) -> Void) {
        guard let name = exercise.name,
              !doesExerciseExist(name: name) else {
            completion(.failure(.createFail))
            return
        }

        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.exercises.append(exercise)
            realm?.objects(ExercisesList.self).first?.exercises.sort()
        }

        updateExerciseDictionary(exercise: exercise, updateType: .create)
        completion(.success(nil))
    }

    func update(_ currentName: String,
                exercise: Exercise,
                completion: @escaping(Result<Any?, DataError>) -> Void) {
        guard let newName = exercise.name,
            let index = allExercisesIndex(of: currentName) else {
            completion(.failure(.updateFail))
            return
        }

        if currentName == newName {
            try? realm?.write {
                realm?.objects(ExercisesList.self).first?.exercises[index] = exercise
            }
            updateExerciseDictionary(exercise: exercise, updateType: .replace)
            completion(.success(nil))
        } else {
            guard !doesExerciseExist(name: newName) else {
                completion(.failure(.updateFail))
                return
            }

            try? realm?.write {
                realm?.objects(ExercisesList.self).first?.exercises.remove(at: index)
                realm?.objects(ExercisesList.self).first?.exercises.append(exercise)
                realm?.objects(ExercisesList.self).first?.exercises.sort()
            }

            updateExerciseDictionary(exercise: exercise, updateType: .create)
            let exerciseToRemove = self.exercise(for: currentName)
            updateExerciseDictionary(exercise: exerciseToRemove, updateType: .remove)
            completion(.success(nil))
        }
    }

    func removeExercise(named: String?) {
        guard let name = named,
            let index = allExercisesIndex(of: name) else {
            return
        }

        let exercise = self.exercise(for: name)
        Utility.removeExerciseImages(names: Array(exercise.imageNames))

        try? realm?.write {
            realm?.objects(ExercisesList.self).first?.exercises.remove(at: index)
        }
        updateExerciseDictionary(exercise: exercise, updateType: .remove)
    }
}

// MARK: - UITableViewDataSource
extension ExercisesTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        correctDictionary.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        let key = getCorrectKey(for: section)
        return correctDictionary[key]?.count ?? 0
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseTVCell.reuseIdentifier,
            for: indexPath) as? ExerciseTVCell else {
            fatalError("Could not dequeue \(ExerciseTVCell.reuseIdentifier)")
        }

        let exercise = self.exercise(for: indexPath)
        cell.configure(dataModel: exercise)

        handleCellSelectionState(exerciseName: exercise.name ?? "",
                                 in: tableView,
                                 indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard presentationStyle == .normal else {
            return false
        }

        let exercise = self.exercise(for: indexPath)
        return exercise.isUserMade
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sections
    }
}

// MARK: - UISearchResultsUpdating
extension ExercisesTVDS: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar

        guard let filtered = searchBar.text?.uppercased(),
            !filtered.isEmpty else {
            filter.removeAll()
            listDataSources?.last?.reloadData()
            return
        }

        filter = filtered
        listDataSources?.last?.reloadData()
    }
}
