//
//  ImagesTableViewCellDelegate.swift
//  Gymbo
//
//  Created by Rohan Sharma on 6/20/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

protocol ImagesTableViewCellDelegate: class {
    func buttonTapped(cell: ImagesTableViewCell, index: Int, function: ButtonFunction)
}
