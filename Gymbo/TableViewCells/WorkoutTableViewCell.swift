//
//  WorkoutTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 9/25/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    @IBOutlet weak var exerciseNameLabel: UILabel!
    @IBOutlet weak var muscleGroupsLabel: UILabel!


    override var reuseIdentifier: String {
        return "WorkoutTableViewCell"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Do nothing
    }
}
