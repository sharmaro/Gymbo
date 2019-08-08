//
//  AddSessionViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/6/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

protocol DimmingViewDelegate: class {
    func animateDimmingView(type: AnimationType)
}

enum AnimationType {
    case darken
    case brighten
}

import UIKit

class AddSessionViewController: UIViewController {
    @IBOutlet weak var sessionNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addExerciseButton: CustomButton!
    
    private lazy var saveButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 45, height: 20)))
        button.setTitle("Save", for: .normal)
        button.titleFontSize = 12
        button.makeRound()
        button.addTarget(self, action: #selector(saveButton(_:)), for: .touchUpInside)
        return button
    }()
    
    private var sessionNameTextFieldOriginY: CGFloat!
    
    private var defaultSessionNameLabelText = "Session name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Session"
        
        sessionNameTextField.borderStyle = .none
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        sessionNameTextFieldOriginY = sessionNameTextField.frame.origin.y
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.isHidden = true
        
        addExerciseButton.setTitle("Add \nExercise", for: .normal)
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.makeRound(addExerciseButton.bounds.width / 2)
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
    
    @objc func saveButton(_ button: CustomButton) {
        print("save button pressed")
        // TODO: Create another popup here that says you can't create a session with empty text
        guard let text = sessionNameTextField.text, text.count > 0 else {
            print("Can't save a session with an empty name")
            return
        }
        
        if let dataModel = SessionsViewController.sessionDataModel {
            var doesSessionExist = false
            for session in dataModel {
                if session.sessionName == text {
                    doesSessionExist.toggle()
                    break
                }
            }
            if doesSessionExist {
                // TODO:
                // Create a popup saying that this name isn't allowed
            } else {
                let sessionModel = SessionDataModel(sessionName: text, workouts: [Workout]())
                SessionsViewController.sessionDataModel?.append(sessionModel)
            }
        } else {
            let sessionModel = SessionDataModel(sessionName: text, workouts: [Workout]())
            SessionsViewController.sessionDataModel = [sessionModel]
        }
        // TODO: add call to reload SessionsVC table view here
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addExerciseButtonTapped(_ sender: Any) {
        if sender is UIButton,
            let addExerciseViewController = storyboard?.instantiateViewController(withIdentifier: "AddExerciseViewController") as? AddExerciseViewController {
            
            animateDimmingView(type: .darken)
            addExerciseViewController.modalPresentationStyle = .custom
            addExerciseViewController.dimmingViewDelegate = self
            present(addExerciseViewController, animated: true, completion: nil)
        } else {
            fatalError("Could not instantiate AddExerciseViewController.")
            
        }
    }
}

extension AddSessionViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension AddSessionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected cell at index path: \(indexPath).")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = -scrollView.contentOffset.y
        if yOffset > 0 {
            sessionNameTextField.frame.origin.y = yOffset + sessionNameTextFieldOriginY
        }
    }
}

extension AddSessionViewController: DimmingViewDelegate {
    func animateDimmingView(type: AnimationType) {
        switch type {
        case .darken:
            animateDarkenView()
        case .brighten:
            animateBrightenView()
        }
    }
}
