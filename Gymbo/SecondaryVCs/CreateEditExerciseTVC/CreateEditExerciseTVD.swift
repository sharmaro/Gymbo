//
//  CreateEditExerciseTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class CreateEditExerciseTVD: NSObject {
    private let heights: [[CGFloat]] = [
        [
            UITableView.automaticDimension, UITableView.automaticDimension,
            UITableView.automaticDimension, Constants.muscleGroupsCellHeight,
            UITableView.automaticDimension, Constants.imagesCellHeight,
            UITableView.automaticDimension, UITableView.automaticDimension,
            UITableView.automaticDimension, UITableView.automaticDimension
        ]
    ]
}

// MARK: - Structs/Enums
private extension CreateEditExerciseTVD {
    struct Constants {
        static let muscleGroupsCellHeight = CGFloat(150)
        static let imagesCellHeight = CGFloat(100)
    }
}

// MARK: - UITableViewDelegate
extension CreateEditExerciseTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        heights[indexPath.section][indexPath.row]
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        heights[indexPath.section][indexPath.row]
    }
}
