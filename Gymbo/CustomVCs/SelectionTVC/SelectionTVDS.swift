//
//  SelectionTVDS.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/30/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SelectionTVDS: NSObject {
    private var items: [String]
    private var selected: String

    weak var selectionDelegate: SelectionDelegate?

    init(items: [String],
         selected: String) {
        self.items = items
        self.selected = selected
        super.init()
    }
}

// MARK: - Funcs
extension SelectionTVDS {
    func item(for indexPath: IndexPath) -> String {
        items[indexPath.row]
    }
}

// MARK: - UITableViewDataSource
extension SelectionTVDS: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LabelTVCell.reuseIdentifier,
                for: indexPath) as? LabelTVCell else {
            fatalError("Could not dequeue \(LabelTVCell.reuseIdentifier)")
        }

        let item = items[indexPath.row]
        cell.configure(text: item)

        if item == selected {
            cell.showsRightImage = true
            cell.rightImageView.image = UIImage(named: "checkmark")?
                .withRenderingMode(.alwaysTemplate)
        } else {
            cell.showsRightImage = false
            cell.rightImageView.image = nil
        }
        Utility.configureCellRounding(in: tableView,
                                      with: cell,
                                      for: indexPath)
        return cell
    }
}
