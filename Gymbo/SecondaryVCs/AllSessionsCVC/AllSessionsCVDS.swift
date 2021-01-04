//
//  AllSessionsCVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/1/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import RealmSwift

// MARK: - Properties
class AllSessionsCVDS: NSObject {
    private(set)var user: User?
    private var itemMode = ItemMode.all

    private var items: [Session] {
        let sessions: [Session]
        switch itemMode {
        case .all:
            sessions = Array(user?.allSessions ?? List<Session>())
        case .canceled:
            sessions = Array(user?.canceledSessions ?? List<Session>())
        case .finished:
            sessions = Array(user?.finishedSessions ?? List<Session>())
        }
        return sessions
    }

    private weak var listDataSource: ListDataSource?

    let segmentedControlItems = ["All", "Canceled", "Finished"]

    init(listDataSource: ListDataSource?, user: User?) {
        super.init()

        self.user = user
        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension AllSessionsCVDS {
    enum ItemMode: Int {
        case all
        case canceled
        case finished
    }
}

// MARK: - Funcs
extension AllSessionsCVDS {
    func itemModeChanged(to modeIndex: Int) {
        guard let itemMode = ItemMode(rawValue: modeIndex) else {
            return
        }
        self.itemMode = itemMode
    }

    func session(for index: Int) -> Session {
        items[index]
    }
}

// MARK: - UICollectionViewDataSource
extension AllSessionsCVDS: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: AllSessionsCVCell.reuseIdentifier,
                for: indexPath) as? AllSessionsCVCell else {
            fatalError("Could not dequeue \(AllSessionsCVCell.reuseIdentifier)")
        }

        let session = items[indexPath.row]
        cell.configure(index: indexPath.row + 1, session: session)
        return cell
    }
}
