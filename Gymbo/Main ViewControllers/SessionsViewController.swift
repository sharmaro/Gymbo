//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class SessionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSessionButton: CustomButton!
    @IBOutlet weak var emptyExerciseLabel: UILabel!
    
    public static var sessionDataModel: [SessionDataModel]?
    
    private let collectionViewCellID = "MenuBarCollectionViewCell"
    // TODO: Create a private id for custom UITableViewCell
    
    private struct Constants {
        public static let animationTime = CGFloat(0.2)
        public static let normalAlphe = CGFloat(1.0)
        public static let darkenedAlpha = CGFloat(0.1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        fetchData()
        setupAddSessionButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchData()
    }
    
    // MARK: - Helper funcs
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func fetchData() {
        if let dataModelCount = SessionsViewController.sessionDataModel?.count {
            tableView.isHidden = dataModelCount == 0
            emptyExerciseLabel.isHidden = !tableView.isHidden
        } else {
            tableView.isHidden = true
            emptyExerciseLabel.isHidden = !tableView.isHidden
        }
        tableView.reloadData()
    }
    
    private func setupAddSessionButton() {
        addSessionButton.setTitle("Add \nSession", for: .normal)
        addSessionButton.titleLabel?.textAlignment = .center
        addSessionButton.makeRound(addSessionButton.bounds.width / 2)
    }
    
    // MARK: - IBAction methods
    
    @IBAction func addSessionButtonPressed(_ sender: Any) {
        if sender is UIButton,
            let sessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddSessionViewController") as? AddSessionViewController {
            sessionViewController.modalPresentationStyle = .custom
        navigationController?.pushViewController(sessionViewController, animated: true)
        } else {
            fatalError("Could not instantiate AddSessionViewController.")
            
        }
    }
}

extension SessionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SessionsViewController.sessionDataModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO:
        guard let data = SessionsViewController.sessionDataModel, let workouts = data[indexPath.section].workouts else {
            fatalError("Cell for row at called with empty data model.")
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = data[indexPath.row].sessionName
        return cell
    }
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath)")
    }
}

// TODO: Create custom UITableViewCell class
