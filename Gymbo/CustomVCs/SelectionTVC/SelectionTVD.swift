//
//  SelectionTVD.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionTVD: NSObject {
    private weak var listDelegate: ListDelegate?

    init(listDelegate: ListDelegate?) {
        super.init()
        self.listDelegate = listDelegate
    }
}

// MARK: - Structs/Enums
private extension SelectionTVD {
    struct Constants {
        static let labelTVCellHeight = CGFloat(70)
    }
}

// MARK: - Funcs
extension SelectionTVD {
}

// MARK: - UITableViewDelegate
extension SelectionTVD: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.labelTVCellHeight
    }
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.labelTVCellHeight
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        listDelegate?.didSelectItem(at: indexPath)
    }
}
