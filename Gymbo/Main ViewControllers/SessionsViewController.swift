//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol SessionDataModelDelegate: class {
    func updateSessionDataModel(sessionName: String?, workoutsList: [Workout])
}

import UIKit

class SessionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSessionButton: CustomButton!
    @IBOutlet weak var emptyExerciseLabel: UILabel!
    
    private var sessionDataModel = [SessionDataModel]()
    
    private struct Constants {
        static let animationTime = CGFloat(0.2)
        static let normalAlphe = CGFloat(1.0)
        static let darkenedAlpha = CGFloat(0.1)
        
        static let sessionTitleHeight = CGFloat(24)
        static let sessionCellLineHeight = CGFloat(22)
        static let cellSeparatorHeight = CGFloat(14)
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
        
        tableView.register(UINib(nibName: "SessionsTableViewCell", bundle: nil), forCellReuseIdentifier: SessionsTableViewCell().reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
    }
    
    private func fetchData() {
        // Get session data model data from storage here
        tableView.isHidden = sessionDataModel.count == 0
        emptyExerciseLabel.isHidden = !tableView.isHidden
        tableView.reloadData()
    }
    
    private func setupAddSessionButton() {
        addSessionButton.setTitle("Add \nSession", for: .normal)
        addSessionButton.titleLabel?.textAlignment = .center
        addSessionButton.addCornerRadius(addSessionButton.bounds.width / 2)
    }
    
    // MARK: - IBAction methods
    
    @IBAction func addSessionButtonPressed(_ sender: Any) {
        if sender is UIButton,
            let sessionViewController = storyboard?.instantiateViewController(withIdentifier: "AddSessionViewController") as? AddSessionViewController {
            sessionViewController.modalPresentationStyle = .custom
            sessionViewController.sessionDataModelDelegate = self
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
        return sessionDataModel.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let workoutsCount = sessionDataModel[indexPath.row].workouts?.count, workoutsCount > 0 else {
            return Constants.sessionTitleHeight + Constants.sessionCellLineHeight + Constants.cellSeparatorHeight
        }
        return (Constants.sessionCellLineHeight * CGFloat(workoutsCount)) + Constants.sessionTitleHeight + Constants.cellSeparatorHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SessionsTableViewCell().reuseIdentifier, for: indexPath) as? SessionsTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(SessionsTableViewCell().reuseIdentifier)`.")
        }
        
        cell.clearLabels()
        if let workouts = sessionDataModel[indexPath.row].workouts, workouts.count > 0 {
            for i in 0..<workouts.count {
                var totalWorkoutString = ""
                let name = workouts[i].name ?? "No name"
                let setsInt = workouts[i].sets ?? 1
                let setsString = setsInt > 1 ? "\(setsInt) sets" : "\(setsInt) set"
                var reps = ""
                if workouts[i].areRepsUnique() {
                    reps = "unique reps"
                } else {
                    reps = workouts[i].workoutDetails?[0].reps?.formattedValue(type: .reps) ?? ""
                }
                totalWorkoutString = "\(name) - \(setsString) x \(reps)"
                if i != workouts.count - 1 {
                    totalWorkoutString += "\n"
                }
                cell.workoutsInfoLabel.text?.append(totalWorkoutString)
            }
        } else {
            cell.workoutsInfoLabel.text = "No workouts selected for this session."
        }
        cell.sessionTitleLabel.text = sessionDataModel[indexPath.row].sessionName ?? "No Name"
        return cell
    }
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath)")
        // Give option to start session/cancel/edit
    }
}

extension SessionsViewController: SessionDataModelDelegate {
    func updateSessionDataModel(sessionName: String?, workoutsList: [Workout]) {
        sessionDataModel.append(SessionDataModel(sessionName: sessionName, workouts: workoutsList))
        tableView.reloadData()
    }
}
