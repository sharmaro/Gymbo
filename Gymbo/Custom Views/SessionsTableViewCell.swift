//
//  SessionsTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class SessionsTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var setsLabel: UILabel!
    @IBOutlet weak var repsLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var setsValueLabel: UILabel!
    @IBOutlet weak var repsValueLabel: UILabel!
    @IBOutlet weak var weightValueLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var additionalInfoTextView: UITextView!
    
    override var reuseIdentifier: String {
        return "SessionsTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
