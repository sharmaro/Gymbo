//
//  AllSessionsDetailTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 1/2/21.
//  Copyright © 2021 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class AllSessionsDetailTVD: NSObject {
    private let session: Session?

    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?, session: Session?) {
        self.session = session
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension AllSessionsDetailTVD {
    enum Constants {
        static let headerHeight = CGFloat(40)
        static let cellHeight = CGFloat(50)
    }
}

// MARK: - Funcs
extension AllSessionsDetailTVD {
}

// MARK: - UITableViewDelegate
extension AllSessionsDetailTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        Constants.headerHeight
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: ExercisesHFV.reuseIdentifier)
                as? ExercisesHFV else {
            return nil
        }
        return view
    }

    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }

    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.cellHeight
    }
}
