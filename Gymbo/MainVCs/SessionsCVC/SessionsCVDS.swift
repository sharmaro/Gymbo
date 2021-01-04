//
//  SessionsCVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class SessionsCVDS: NSObject {
    private var realm: Realm? {
        try? Realm()
    }

    private var sessionsList: SessionsList? {
        realm?.objects(SessionsList.self).first
    }

    private weak var listDataSource: ListDataSource?

    var user: User?

    var dataState = DataState.notEditing {
        didSet {
            listDataSource?.dataStateChanged()
        }
    }

    var isEmpty: Bool {
        sessionsList?.sessions.isEmpty ?? true
    }

    init(listDataSource: ListDataSource?, user: User?) {
        self.user = user
        super.init()

        self.listDataSource = listDataSource
        loadSessions()
    }
}

// MARK: - Funcs
extension SessionsCVDS {
    private func loadSessions() {
        printConfigFileLocation()

        // Add a sample session for first time downloads
        if realm?.objects(SessionsList.self).first == nil {
            let sampleExercise = Exercise(name: "Sample Exercise",
                                          groups: "sample groups",
                                          instructions: "Sample Instructions",
                                          tips: "Sample Tips",
                                          isUserMade: false,
                                          weightType: WeightType.lbs.rawValue)
            let sampleExerciseList = List<Exercise>()
            sampleExerciseList.append(sampleExercise)
            let sampleSession = Session(name: "Sample", info: "Sample Info", exercises: sampleExerciseList)

            let list = SessionsList()
            list.sessions.append(sampleSession)
            try? realm?.write {
                realm?.add(list)
            }
        }
    }

    // Delete this eventually
    private func printConfigFileLocation() {
        if let fileURL = realm?.configuration.fileURL {
            NSLog("SUCCESS: Realm location exists.")
            print("\(fileURL)\n")
        } else {
            NSLog("FAILURE: Realm location does not exist.")
        }
    }

    private func check(_ index: Int) -> SessionsList {
        guard let list = sessionsList,
            index > -1,
            index < list.sessions.count else {
                fatalError("Can't interact with session at index \(index)")
        }
        return list
    }

    func index(of name: String) -> Int? {
        sessionsList?.sessions.firstIndex(where: {
            $0.name == name
        })
    }

    func session(for index: Int) -> Session? {
        sessionsList?.sessions[index]
    }

    func sessionInfoText(for index: Int) -> String {
        guard let exercises = sessionsList?.sessions[index].exercises,
              !exercises.isEmpty else {
            return "No exercises in this session."
        }

        var sessionInfoText = ""
        for i in 0 ..< exercises.count {
            var sessionString = ""
            let name = Utility.formattedString(stringToFormat: exercises[i].name, type: .name)
            sessionString = "\(name)"
            if i != exercises.count - 1 {
                sessionString += ", "
            }
            sessionInfoText.append(sessionString)
        }
        return sessionInfoText
    }

    func create(session: Session, completion: @escaping(Result<Any?, DataError>) -> Void) {
        guard let list = sessionsList,
              index(of: session.name ?? "") == nil else {
            completion(.failure(.createFail))
            return
        }

        try? realm?.write {
            list.sessions.append(session)
            completion(.success(nil))
        }
    }

    func update(_ currentName: String,
                session: Session,
                completion: @escaping(Result<Any?, DataError>) -> Void) {
        guard let newName = session.name,
            let index = index(of: currentName) else {
            completion(.failure(.updateFail))
            return
        }

        if currentName == newName {
            try? realm?.write {
                sessionsList?.sessions[index] = session
                completion(.success(nil))
            }
        } else {
            guard self.index(of: newName) == nil else {
                completion(.failure(.updateFail))
                return
            }

            try? realm?.write {
                sessionsList?.sessions.remove(at: index)
                sessionsList?.sessions.append(session)
                completion(.success(nil))
            }
        }
    }

    func insert(session: Session, at index: Int) {
        // Can't insert into array at an index that's 1 + array.count
        guard let list = sessionsList, index > -1,
            index < list.sessions.count + 1 else {
                fatalError("Can't insert session at index \(index)")
        }

        try? realm?.write {
            list.sessions.insert(session, at: index)
        }
    }

    func remove(at index: Int) {
        let list = check(index)

        try? realm?.write {
            list.sessions.remove(at: index)
        }
    }

    func removeInstancesOfExercise(name: String?) {
        guard let name = name else {
            return
        }

        if let sessions = sessionsList?.sessions {
            for session in sessions {
                let exercises = session.exercises
                if let index = exercises.firstIndex(where: {
                    $0.name == name
                }) {
                    try? realm?.write {
                        exercises.remove(at: index)
                    }
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SessionsCVDS: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        sessionsList?.sessions.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let sessionsCVCell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SessionsCVCell.reuseIdentifier,
                for: indexPath) as? SessionsCVCell else {
            fatalError("Could not dequeue \(SessionsCVCell.reuseIdentifier)")
        }

        var dataModel = SessionsCVCellModel()
        dataModel.title = sessionsList?
            .sessions[indexPath.row].name ?? "No name"
        dataModel.info = sessionInfoText(for: indexPath.row)
        dataModel.isEditing = dataState == .editing

        sessionsCVCell.alpha = 1
        sessionsCVCell.configure(dataModel: dataModel)
        sessionsCVCell.sessionsCVCellDelegate = self
        return sessionsCVCell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDragDelegate
extension SessionsCVDS: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {

        guard let session = self.session(for: indexPath.row) else {
            return [UIDragItem]()
        }

        let itemProvider = NSItemProvider(object: session)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = session
        return [dragItem]
    }

    // Used for showing the view when the session is being dragged
    func collectionView(_ collectionView: UICollectionView,
                        dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SessionsCVCell else {
            return nil
        }

        let previewParameters = UIDragPreviewParameters()
        let path = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 10)

        previewParameters.visiblePath = path
        previewParameters.backgroundColor = .clear
        return previewParameters
    }
}

// MARK: - UICollectionViewDropDelegate
extension SessionsCVDS: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?)
        -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }

    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        // It helps to use the (0, 0) if there is only one cell
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(row: 0, section: 0)

        switch coordinator.proposal.operation {
        case .move:
            let items = coordinator.items
            for item in items {
                guard let sourceIndexPath = item.sourceIndexPath,
                    let fromSession = session(for: sourceIndexPath.row) else {
                    return
                }

                remove(at: sourceIndexPath.item)
                insert(session: fromSession, at: destinationIndexPath.item)

                collectionView.performBatchUpdates({
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                })
                coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
            }
        default:
            return
        }
    }
}

// MARK: - SessionsCVCellDelegate
extension SessionsCVDS: SessionsCVCellDelegate {
    func delete(cell: SessionsCVCell) {
        listDataSource?.deleteCell(cvCell: cell)
    }
}
