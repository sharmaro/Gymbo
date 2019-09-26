//
//  SessionsTableViewCell.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class SessionsTableViewCell: UITableViewCell {
    @IBOutlet weak var sessionTitleLabel: UILabel!
    @IBOutlet weak var workoutsInfoLabel: UILabel!
    
    override var reuseIdentifier: String {
        return "SessionsTableViewCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLabel()
        setupContentView()
    }
    
    private func setupLabel() {
        workoutsInfoLabel.numberOfLines = 0
    }

    private func setupContentView() {
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.black.cgColor
    }
    
    func clearLabels() {
        sessionTitleLabel.text?.removeAll()
        workoutsInfoLabel.text?.removeAll()
    }
}