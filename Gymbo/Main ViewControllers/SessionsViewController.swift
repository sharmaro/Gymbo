//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol SessionDataModelDelegate: class {
    func updateSessionDataModel(name: String?, workouts: List<Workout>)
}

import UIKit
import RealmSwift

class SessionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSessionButton: CustomButton!
    @IBOutlet weak var emptyExerciseLabel: UILabel!
    
    private let dataModelManager = SessionDataModelManager.shared
    
    private struct Constants {
        static let animationTime = CGFloat(0.2)
        static let normalAlphe = CGFloat(1.0)
        static let darkenedAlpha = CGFloat(0.1)
        
        static let sessionTitleHeight = CGFloat(24)
        static let sessionCellLineHeight = CGFloat(22)
        static let cellSeparatorHeight = CGFloat(14)
        static let emptyWorkoutCellHeight = CGFloat(60)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
//        refreshMainView()
        setupAddSessionButton()

        // Delete this
        if let tempVC = storyboard?.instantiateViewController(withIdentifier: "tempVC") as? TempViewController {
            present(tempVC, animated: true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        refreshMainView()
    }
    
    // MARK: - Helper funcs
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "SessionsTableViewCell", bundle: nil), forCellReuseIdentifier: SessionsTableViewCell().reuseIdentifier)
        tableView.keyboardDismissMode = .interactive
    }

    private func refreshMainView() {
        tableView.isHidden = dataModelManager.sessionsCount == 0
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
        return dataModelManager.sessionsCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let workoutsCount = CGFloat(dataModelManager.workoutsCountForSession(index: indexPath.row))
        guard workoutsCount > 0 else {
            return Constants.emptyWorkoutCellHeight
        }
        
        return (Constants.sessionCellLineHeight * workoutsCount) + Constants.sessionTitleHeight + Constants.cellSeparatorHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SessionsTableViewCell().reuseIdentifier, for: indexPath) as? SessionsTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(SessionsTableViewCell().reuseIdentifier)`.")
        }
        
        cell.clearLabels()
        cell.sessionTitleLabel.text = dataModelManager.getSessionNameForIndex(index: indexPath.row)
        cell.workoutsInfoLabel.text = dataModelManager.workoutsInfoTextForSession(index: indexPath.row)

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
    func updateSessionDataModel(name: String?, workouts: List<Workout>) {
        let session = Session(name: name, workouts: workouts)
        dataModelManager.saveSession(session: session)

        refreshMainView()
    }
}

class TempViewController: UIViewController {
    @IBAction func keepData(_ sender: Any) {
        dismiss(animated: true)
    }


    @IBAction func deleteData(_ sender: Any) {
        SessionDataModelManager.shared.removeAllRealmData()
        dismiss(animated: true)
    }
}
