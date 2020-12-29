//
//  ExercisePreviewTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisePreviewTVD: NSObject {
    var exercise = Exercise()
}

// MARK: - Structs/Enums
private extension ExercisePreviewTVD {
    struct Constants {
        static let swipableImageVTVCellHeight = CGFloat(200)
    }
}

// MARK: - Funcs
extension ExercisePreviewTVD {
    private func height(for indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 2 {
            return exercise.imageNames.isEmpty ?
                UITableView.automaticDimension : Constants.swipableImageVTVCellHeight
        }
        return UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension ExercisePreviewTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        height(for: indexPath)
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        height(for: indexPath)
    }
}
