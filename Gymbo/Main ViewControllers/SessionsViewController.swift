//
//  SessionsViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 7/7/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol DimmingViewDelegate: class {
    func animateDimmingView(type: AnimationType)
}

enum AnimationType {
    case show
    case hide
}

class SessionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addSessionButton: UIButton!
    @IBOutlet weak var emptyExerciseLabel: UILabel!
    
    private var dataModel: [SessionDataModel]?
    
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
        
        var workouts = [Workout]()
        for i in 0..<20 {
            let workout = Workout(name: "name: \(i)", sets: i, reps: i, weight: Double(i), time: i, additionalInfo: "add. info: \(i)")
            workouts.append(workout)
        }
        dataModel = [SessionDataModel(workouts: workouts)]
    }
    
    // MARK: - Helper funcs
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func fetchData() {
//        tableView.isHidden = true
    }
    
    private func setupAddSessionButton() {
        addSessionButton.setTitle("Add \nSession", for: .normal)
        addSessionButton.setTitleColor(.black, for: .normal)
        addSessionButton.titleLabel?.textAlignment = .center
        addSessionButton.backgroundColor = .lightGray
        addSessionButton.layer.cornerRadius = addSessionButton.bounds.width / 2
    }
    
    private func updateViewFromMenuButton() {
        // TODO:
    }
    
    private func animateDarkenView() {
        
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.view.alpha = 0.3
        }
    }
    
    private func animateBrightenView() {
        UIView.animate(withDuration: 0.2) {
            self.navigationController?.view.alpha = 1.0
        }
    }
    
    // MARK: - IBAction methods
    
    @IBAction func addSessionButtonPressed(_ sender: Any) {
        if sender is UIButton,
            let viewController = storyboard?.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {
            viewController.modalPresentationStyle = .custom
            viewController.dimmingViewDelegate = self
            animateDimmingView(type: .show)
            present(viewController, animated: true, completion: nil)
        } else {
            fatalError("Could not instantiate AddExerciseViewController.")
            
        }
    }
}

extension SessionsViewController: DimmingViewDelegate {
    func animateDimmingView(type: AnimationType) {
        switch type {
        case .show:
            animateDarkenView()
        case .hide:
            animateBrightenView()
        }
    }
}

extension SessionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataModel?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel?[section].workouts?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO:
        guard let data = dataModel, let workouts = data[indexPath.section].workouts else {
            fatalError("Cell for row at called with empty data model.")
        }
        
        let cell = UITableViewCell()
        cell.textLabel?.text = workouts[indexPath.row].name
        return cell
    }
}

extension SessionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected row at indexPath: \(indexPath)")
    }
}

// TODO: Create custom UITableViewCell class
