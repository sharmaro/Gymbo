//
//  SessionPreviewTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionPreviewTVDS: NSObject {
    var session: Session?
}

// MARK: - Structs/Enums
extension SessionPreviewTVDS {
    private struct Constants {
        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
    }
}

// MARK: - Funcs
extension SessionPreviewTVDS {
    func getSessionHeaderViewModel() -> SessionHeaderViewModel {
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .primaryText
        return dataModel
    }
}

// MARK: - UITableViewDataSource
extension SessionPreviewTVDS: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        session?.exercises.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let exerciseTVCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseTVCell.reuseIdentifier,
            for: indexPath) as? ExerciseTVCell,
              let exercise = session?.exercises[indexPath.row] else {
            fatalError("Could not dequeue \(ExerciseTVCell.reuseIdentifier)")
        }

        exerciseTVCell.configure(dataModel: exercise)
        return exerciseTVCell
    }
}
