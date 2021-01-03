//
//  StopwatchTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class StopwatchTVD: NSObject {
    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate? = nil) {
        super.init()
    }
}

// MARK: - Structs/Enums
private extension StopwatchTVD {
    struct Constants {
        static let cellHeight = CGFloat(50)
    }
}

// MARK: - UITableViewDelegate
extension StopwatchTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }

    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        cell.alpha = 0

        UIView.animate(withDuration: .defaultAnimationTime) {
            cell.alpha = 1
        }
    }
}
