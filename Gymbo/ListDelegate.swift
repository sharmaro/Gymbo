//
//  ListDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 12/26/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ListDelegate: class {
    func didSelectItem(at IndexPath: IndexPath)
    func didDeselectItem(at IndexPath: IndexPath)
}

extension ListDelegate {
    func didSelectItem(at IndexPath: IndexPath) {}
    func didDeselectItem(at IndexPath: IndexPath) {}
}
