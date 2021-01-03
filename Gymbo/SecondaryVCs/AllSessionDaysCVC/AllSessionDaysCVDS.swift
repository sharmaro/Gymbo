//
//  AllSessionDaysCVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionDaysCVDS: NSObject {
    private var user: User?
    var date: Date

    var dates: [Date] {
        user?.uniqueDates ?? []
    }

    private var sessions: [Session] {
        user?.sessions(for: date) ?? []
    }

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?, user: User?, date: Date) {
        self.user = user
        self.date = date
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Funcs
extension AllSessionDaysCVDS {
    func selected(index: Int) {
        date = dates[index]
    }

    func session(for index: Int) -> Session {
        sessions[index]
    }
}

// MARK: - UICollectionViewDataSource
extension AllSessionDaysCVDS: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        sessions.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TwoLabelsCVCell.reuseIdentifier,
                for: indexPath) as? TwoLabelsCVCell else {
            fatalError("Could not dequeue \(TwoLabelsCVCell.reuseIdentifier)")
        }

        let sessionName = sessions[indexPath.row].name ?? ""
        let dateString = date.formattedString(type: .medium)
        cell.configure(topText: sessionName,
                       bottomText: dateString)
        return cell
    }
}
