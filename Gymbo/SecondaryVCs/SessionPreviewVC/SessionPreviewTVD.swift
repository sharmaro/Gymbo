//
//  SessionPreviewTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/29/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionPreviewTVD: NSObject {}

// MARK: - Structs/Enums
private extension SessionPreviewTVD {
    struct Constants {
        static let exerciseCellHeight = CGFloat(70)
    }
}

// MARK: - Funcs
extension SessionPreviewTVD {
}

// MARK: - UITableViewDelegate
extension SessionPreviewTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.exerciseCellHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.exerciseCellHeight
    }
}
