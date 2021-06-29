//
//  StartedSessionTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class StartedSessionTVDS: NSObject {
    var session: Session?
    var selectedRows = Set<IndexPath>()
    var modallyPresenting = ModallyPresenting.none

    weak var sessionProgresssDelegate: SessionProgressDelegate?

    private var realm: Realm? {
        try? Realm()
    }

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?) {
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension StartedSessionTVDS {
    private enum Constants {
        static let buttonText = "+ Set"
        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"

        static let exerciseHeaderCellHeight = CGFloat(67)
        static let exerciseDetailCellHeight = CGFloat(40)
        static let buttonCellHeight = CGFloat(65)
    }

    enum ModallyPresenting {
        case restVC
        case exercisesVC
        case none
    }
}

// MARK: - Funcs
extension StartedSessionTVDS {
    private func getExerciseHeaderTVCell(in tableView: UITableView,
                                         for indexPath: IndexPath,
                                         session: Session) -> ExerciseHeaderTVCell {
        guard let exerciseHeaderTVCell = tableView.dequeueReusableCell(
                withIdentifier: ExerciseHeaderTVCell.reuseIdentifier,
                for: indexPath) as? ExerciseHeaderTVCell else {
            fatalError("Could not dequeue \(ExerciseHeaderTVCell.reuseIdentifier)")
        }

        var dataModel = ExerciseHeaderTVCellModel()
        dataModel.name = session.exercises[indexPath.section].name
        dataModel.weightType = session.exercises[indexPath.section].weightType
        dataModel.isDoneButtonImageHidden = false

        exerciseHeaderTVCell.configure(dataModel: dataModel)
        return exerciseHeaderTVCell
    }

    private func getButtonTVCell(in tableView: UITableView,
                                 for indexPath: IndexPath) -> ButtonTVCell {
        guard let buttonTVCell = tableView.dequeueReusableCell(
                withIdentifier: ButtonTVCell.reuseIdentifier,
                for: indexPath) as? ButtonTVCell else {
            fatalError("Could not dequeue \(ButtonTVCell.reuseIdentifier)")
        }

        buttonTVCell.configure(title: Constants.buttonText,
                                      titleColor: .white,
                                      backgroundColor: .systemGray,
                                      cornerStyle: .small)
        return buttonTVCell
    }

    private func getExerciseDetailTVCell(in tableView: UITableView,
                                         for indexPath: IndexPath,
                                         session: Session) -> ExerciseDetailTVCell {
        guard let exerciseDetailTVCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseDetailTVCell.reuseIdentifier,
            for: indexPath) as? ExerciseDetailTVCell else {
            fatalError("Could not dequeue \(ExerciseDetailTVCell.reuseIdentifier)")
        }

        let exercise = session.exercises[indexPath.section]
        var dataModel = ExerciseDetailTVCellModel()

        dataModel.sets = "\(indexPath.row)"
        dataModel.last = exercise.exerciseDetails[indexPath.row - 1].last ?? "--"
        dataModel.reps = exercise.exerciseDetails[indexPath.row - 1].reps
        dataModel.weight = exercise.exerciseDetails[indexPath.row - 1].weight
        dataModel.isDoneButtonEnabled = true

        exerciseDetailTVCell.configure(dataModel: dataModel)
        exerciseDetailTVCell.didSelect = selectedRows.contains(indexPath)
        return exerciseDetailTVCell
    }

    private func handleCellSelectionState(in tableView: UITableView,
                                          indexPath: IndexPath) {
        if selectedRows.contains(indexPath) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    func didSelect(cell: UITableViewCell,
                   in tableView: UITableView,
                   at indexPath: IndexPath) {
        guard let exerciseDetailCell = cell as? ExerciseDetailTVCell else {
            return
        }

        let containsIndexPath = selectedRows.contains(indexPath)
        if containsIndexPath {
            selectedRows.remove(indexPath)
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            selectedRows.insert(indexPath)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        exerciseDetailCell.didSelect = !containsIndexPath
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let sets = session?.exercises[indexPath.section].sets ?? 0
        switch indexPath.row {
        case 0:
            return Constants.exerciseHeaderCellHeight
        case sets + 1:
            return Constants.buttonCellHeight
        default:
            return Constants.exerciseDetailCellHeight
        }
    }

    func loadData() {
        if let startedSession = realm?.objects(StartedSession.self).first {
            selectedRows.removeAll()
            selectedRows = Set(startedSession.selectedRows.map { $0.indexPath })
        }
    }

    func saveSession() {
        if let session = session {
            let selectedRowsList = List<RealmIndexPath>()
            let convertedObjects = selectedRows.map {
                RealmIndexPath(indexPath: $0)
            }
            selectedRowsList.append(objectsIn: convertedObjects)
            let updatedStartedSession = StartedSession(name: session.name,
                                                info: session.info,
                                                selectedRows: selectedRowsList,
                                                exercises: session.exercises)

            if let startedSession = realm?.objects(StartedSession.self).first {
                try? realm?.write {
                    realm?.delete(startedSession)
                    realm?.add(updatedStartedSession)
                }
            } else {
                try? realm?.write {
                    realm?.add(updatedStartedSession)
                }
            }
        }
    }

    func sessionHeaderViewModel() -> SessionHeaderViewModel {
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .primaryText
        return dataModel
    }

    func addSet(at index: Int) {
        try? realm?.write {
            session?.exercises[index].sets += 1
            session?.exercises[index].exerciseDetails.append(ExerciseDetails())
        }
    }

    func removeSet(in tableView: UITableView, indexPath: IndexPath) {
        guard let session = session else {
            return
        }

        try? realm?.write {
            session.exercises[indexPath.section].sets -= 1
            session.exercises[indexPath.section].exerciseDetails.remove(at: indexPath.row - 1)
        }

        let rowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        let indexToStartAt = indexPath.row + 1
        if indexToStartAt < rowsInSection {
            for i in indexToStartAt..<rowsInSection {
                let currentIndexPath = IndexPath(row: i, section: indexPath.section)
                let newIndexPath = IndexPath(row: i - 1, section: indexPath.section)

                selectedRows.remove(currentIndexPath)
                selectedRows.insert(newIndexPath)
            }
        }
        selectedRows.remove(indexPath)
    }

    func updateExercises(_ exercises: [Exercise]) {
        exercises.forEach {
            let newExercise = $0
            try? realm?.write {
                session?.exercises.append(newExercise)
            }
        }
    }

    func removeExercise(at index: Int) {
        try? realm?.write {
            session?.exercises.remove(at: index)
        }
    }

    func removeStartedSession() {
        if let startedSession = realm?.objects(StartedSession.self).first {
            try? realm?.write {
                realm?.delete(startedSession)
            }
        }
    }

    func updateWeightType(type: Int, at index: Int) {
        try? realm?.write {
            session?.exercises[index].weightType = type
        }
    }

    func saveTextFieldData(_ text: String, textFieldType: TextFieldType,
                           section: Int, row: Int) {
        try? realm?.write {
            switch textFieldType {
            case .reps:
                session?.exercises[section].exerciseDetails[row].reps = text
            case .weight:
                session?.exercises[section].exerciseDetails[row].weight = text
            }
        }
    }

    func sessionDidEnd(sessionSeconds: Int?, endType: EndType) {
        guard let sessionCopy = session?.safeCopy,
              let sessionSeconds = sessionSeconds else {
            return
        }

        sessionCopy.sessionSeconds = sessionSeconds
        sessionProgresssDelegate?.sessionDidEnd(sessionCopy, endType: endType)
    }

    func setLastExerciseDetail() {
        if let session = session {
            for exercise in session.exercises {
                for detail in exercise.exerciseDetails {
                    let weight = Utility.formattedString(
                        stringToFormat: detail.weight,
                        type: .weight)
                    let reps = detail.reps ?? "--"
                    let last: String
                    if weight != "--" && reps != "--" {
                        last = "\(reps) x \(weight)"
                    } else {
                        last = "--"
                    }
                    try? realm?.write {
                        detail.last = last
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension StartedSessionTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        session?.exercises.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        (session?.exercises[section].sets ?? 0) + 2
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let session = session else {
            fatalError("Session is nil in \(String(describing: self))")
        }

        let cell: UITableViewCell
        switch indexPath.row {
        case 0: // Exercise header cell
            cell = getExerciseHeaderTVCell(in: tableView, for: indexPath, session: session)
        case tableView.numberOfRows(inSection: indexPath.section) - 1: // Add set cell
            cell = getButtonTVCell(in: tableView, for: indexPath)
        default: // Exercise detail cell
            cell = getExerciseDetailTVCell(in: tableView, for: indexPath, session: session)
            handleCellSelectionState(in: tableView, indexPath: indexPath)
        }

        listDataSource?.cellForRowAt(tvCell: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        // Protecting the first, second, and last rows because they shouldn't be swipe to delete
        case 0, tableView.numberOfRows(inSection: indexPath.section) - 1:
            return false
        case 1:
            return (session?.exercises[indexPath.section].sets ?? 0) > 1
        default:
            return true
        }
    }
}
