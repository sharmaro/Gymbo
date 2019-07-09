//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

enum Day: String, Codable {
    case Monday = "Mon"
    case Tuesday = "Tue"
    case Wednesday = "Wed"
    case Thursday = "Thu"
    case Friday = "Fri"
    case Saturday = "Sat"
    case Sunday = "Sun"
}

class SessionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var dataModel: [Day: [SessionDataModel]]?
    var selectedDay: Day!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.shadowImage = UIImage()
        
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension SessionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?[selectedDay]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[selectedDay]?[section].workouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath)")
    }
}
