//
//  ProfileTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/28/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ProfileTVDS: NSObject {
    private let items: [[Item]] = [
        [
        ]
    ]

    private weak var listDataSource: ListDataSource?

    init(listDataSource: ListDataSource?) {
        super.init()

        self.listDataSource = listDataSource
    }
}

// MARK: - Structs/Enums
extension ProfileTVDS {
    private struct Constants {
    }

    enum Item {
    }
}

// MARK: - Funcs
extension ProfileTVDS {
}

// MARK: - UITableViewDataSource
extension ProfileTVDS: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items[section].count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
