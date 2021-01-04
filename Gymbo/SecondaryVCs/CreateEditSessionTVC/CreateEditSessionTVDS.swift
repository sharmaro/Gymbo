//
//  CreateEditSessionTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class CreateEditSessionTVDS: NSObject {
    var session = Session()
    var sessionState = SessionState.create
    var previousExerciseDetailInformation: (reps: String?, weight: String?) = ("", "")
    var didAddSet = false

    private var user: User?

    private var realm: Realm? {
        try? Realm()
    }

    weak var sessionDataModelDelegate: SessionDataModelDelegate?

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?, user: User?) {
        self.user = user
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
private extension CreateEditSessionTVDS {
    struct Constants {
        static let buttonText = "+ Set"

        static let exerciseHeaderCellHeight = CGFloat(67)
        static let exerciseDetailCellHeight = CGFloat(40)
        static let buttonCellHeight = CGFloat(65)
    }
}

// MARK: - Funcs
extension CreateEditSessionTVDS {
    private func getExerciseHeaderTVCell(in tableView: UITableView,
                                         for indexPath: IndexPath) -> ExerciseHeaderTVCell {
        guard let exerciseHeaderTVCell = tableView.dequeueReusableCell(
                withIdentifier: ExerciseHeaderTVCell.reuseIdentifier,
                for: indexPath) as? ExerciseHeaderTVCell else {
            fatalError("Could not dequeue \(ExerciseHeaderTVCell.reuseIdentifier)")
        }

        let exercise = session.exercises[indexPath.section]
        var dataModel = ExerciseHeaderTVCellModel()
        dataModel.name = exercise.name
        if sessionState == .create, !exercise.didSetWeightType {
            let rawWeightType = user?
                .preferredWeightType ?? 0
            dataModel.weightType = rawWeightType
            updateExerciseWeightTypeRealm(at: indexPath.section,
                                          weightType: rawWeightType)
        } else {
            dataModel.weightType = exercise.weightType
        }
        dataModel.isDoneButtonImageHidden = true

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
                                         for indexPath: IndexPath) -> ExerciseDetailTVCell {
        guard let exerciseDetailTVCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseDetailTVCell.reuseIdentifier,
            for: indexPath) as? ExerciseDetailTVCell else {
            fatalError("Could not dequeue \(ExerciseDetailTVCell.reuseIdentifier)")
        }

        let indexPathToUse = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        var dataModel = ExerciseDetailTVCellModel()
        dataModel.sets = "\(indexPath.row)"
        let exercise = session.exercises[indexPath.section]
        dataModel.last = exercise.exerciseDetails[indexPath.row - 1].last ?? "--"
        dataModel.isDoneButtonEnabled = false
        if didAddSet {
            dataModel.reps = previousExerciseDetailInformation.reps
            dataModel.weight = previousExerciseDetailInformation.weight

            saveTextFieldsWithOrWithoutRealm(text: dataModel.reps,
                                             textFieldType: .reps,
                                             indexPath: indexPathToUse)
            saveTextFieldsWithOrWithoutRealm(text: dataModel.weight,
                                             textFieldType: .weight,
                                             indexPath: indexPathToUse)

            didAddSet = false
            previousExerciseDetailInformation = ("", "")
        } else {
            let exercise = session.exercises[indexPathToUse.section]
            dataModel.reps = exercise.exerciseDetails[indexPathToUse.row].reps
            dataModel.weight = exercise.exerciseDetails[indexPathToUse.row].weight
        }
        exerciseDetailTVCell.configure(dataModel: dataModel)
        return exerciseDetailTVCell
    }

    private func saveTextFieldData(_ text: String,
                                   textFieldType: TextFieldType,
                                   indexPath: IndexPath) {
        switch textFieldType {
        case .reps:
            session.exercises[indexPath.section].exerciseDetails[indexPath.row].reps = text
        case .weight:
            session.exercises[indexPath.section].exerciseDetails[indexPath.row].weight = text
        }
    }

    private func addSet(section: Int) {
        session.exercises[section].sets += 1
        session.exercises[section].exerciseDetails.append(ExerciseDetails())
    }

    private func deleteSet(indexPath: IndexPath) {
        session.exercises[indexPath.section].sets -= 1
        session.exercises[indexPath.section].exerciseDetails.remove(at: indexPath.row - 1)
    }

    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        let sets = session.exercises[indexPath.section].sets
        switch indexPath.row {
        case 0:
            return Constants.exerciseHeaderCellHeight
        case sets + 1:
            return Constants.buttonCellHeight
        default:
            return Constants.exerciseDetailCellHeight
        }
    }

    func saveTextFieldsWithOrWithoutRealm(text: String?,
                                          textFieldType: TextFieldType,
                                          indexPath: IndexPath) {
        let text = text ?? "--"
        // Decrementing indexPath.row by 1 because the first cell is the exercise header cell
        if sessionState == .create {
            saveTextFieldData(text, textFieldType: textFieldType, indexPath: indexPath)
        } else {
            try? realm?.write {
                saveTextFieldData(text, textFieldType: textFieldType, indexPath: indexPath)
            }
        }
    }

    func addSetRealm(section: Int) {
        if sessionState == .create {
            addSet(section: section)
        } else {
            try? realm?.write {
                addSet(section: section)
            }
        }
    }

    func addExercisesRealm(exercises: [Exercise]) {
        exercises.forEach {
            let newExercise = $0
            if sessionState == .create {
                session.exercises.append(newExercise)
            } else {
                try? realm?.write {
                    session.exercises.append(newExercise)
                }
            }
        }
    }

    func deleteSetRealm(indexPath: IndexPath) {
        if sessionState == .create {
            deleteSet(indexPath: indexPath)
        } else {
            try? realm?.write {
                deleteSet(indexPath: indexPath)
            }
        }
    }

    func deleteExerciseRealm(at index: Int) {
        if sessionState == .create {
            session.exercises.remove(at: index)
        } else {
            try? realm?.write {
                session.exercises.remove(at: index)
            }
        }
    }

    func saveSession(name: String?, info: String?) {
        let sessionToInteractWith = session.safeCopy
        sessionToInteractWith.name = name
        sessionToInteractWith.info = info
        if sessionState == .create {
            sessionDataModelDelegate?.create(sessionToInteractWith,
                                             completion: { _ in
            })
        } else {
            sessionDataModelDelegate?.update(session.name ?? "",
                                             session: sessionToInteractWith,
                                             completion: { _ in
            })
        }
    }

    func updateExerciseWeightTypeRealm(at index: Int, weightType: Int) {
        if sessionState == .create {
            session.exercises[index].weightType = weightType
            session.exercises[index].didSetWeightType = true
        } else {
            try? realm?.write {
                session.exercises[index].weightType = weightType
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension CreateEditSessionTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        session.exercises.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // Adding 1 for exercise name label
        // Adding 1 for "+ Set button"
        session.exercises[section].sets + 2
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch indexPath.row {
        case 0: // Exercise header cell
            cell = getExerciseHeaderTVCell(in: tableView, for: indexPath)
        case tableView.numberOfRows(inSection: indexPath.section) - 1: // Add set cell
            cell = getButtonTVCell(in: tableView, for: indexPath)
        default: // Exercise detail cell
            cell = getExerciseDetailTVCell(in: tableView, for: indexPath)
        }

        listDataSource?.cellForRowAt(tvCell: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        // The first, second, and last rows can't be deleted
        case 0, tableView.numberOfRows(inSection: indexPath.section) - 1:
            return false
        case 1:
            return session.exercises[indexPath.section].sets > 1
        default:
            return true
        }
    }
}
