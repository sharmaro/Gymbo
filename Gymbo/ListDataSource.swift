//
//  ListDataSource.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/27/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ListDataSource: class {
    func reloadData()
    func dataStateChanged()
    func buttonTapped(cell: UITableViewCell, index: Int, function: ButtonFunction)
    func deleteCell(tvCell: UITableViewCell)
    func deleteCell(cvCell: UICollectionViewCell)
    func cellForRowAt(tvCell: UITableViewCell)
}

extension ListDataSource {
    func reloadData() {}
    func dataStateChanged() {}
    func buttonTapped(cell: UITableViewCell, index: Int, function: ButtonFunction) {}
    func deleteCell(tvCell: UITableViewCell) {}
    func deleteCell(cvCell: UICollectionViewCell) {}
    func cellForRowAt(tvCell: UITableViewCell) {}
}
