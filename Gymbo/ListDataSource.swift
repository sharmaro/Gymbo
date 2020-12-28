//
//  ListDataSource.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/27/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ListDataSource: class {
    func updateSearchResults()
}

extension ListDataSource {
    func updateSearchResults() {}
}
