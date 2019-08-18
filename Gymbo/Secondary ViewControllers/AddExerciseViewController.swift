//
//  AddExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

class AddExerciseViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createExerciseButton: CustomButton!
    
    private lazy var cancelButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 20)))
        button.setTitle("Cancel", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(navBarButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var addButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 60, height: 20)))
        button.setTitle("Add", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.isUserInteractionEnabled = false
        button.alpha = 0.3
        button.tag = 1
        button.addTarget(self, action: #selector(navBarButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private var textArray =
        ["Exercise 0", "Exercise 1", "Exercise 2", "Exercise 3", "Exercise 4", "Exercise 5", "Exercise 6", "Exercise 7",
         "Exercise 8", "Exercise 9", "Exercise 10", "Exercise 11", "Exercise 12", "Exercise 13", "Exercise 14", "Exercise 15",
         "Exercise 16", "Exercise 17", "Exercise 18", "Exercise 19", "Exercise 20", "Exercise 21", "Exercise 22", "Exercise 23"]
    
    // For searching exercises
    private var searchedTextArray = [String]()
    private var sortedArray = [[String]]()
    
    private var selectedExercises = [String]()
    
    weak var dimmingViewDelegate: DimmingViewDelegate?
    weak var workoutListDelegate: WorkoutListDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupSearchTextField()
        setupTableView()
        
        createExerciseButton.setTitle("Create New Exercise", for: .normal)
        createExerciseButton.titleLabel?.textAlignment = .center
        createExerciseButton.addCornerRadius()
        
        searchedTextArray = textArray
    }
    
    private func setupView() {
        navigationBar.prefersLargeTitles = false
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 20
    }
    
    private func setupSearchTextField() {
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.borderStyle = .none
        searchTextField.leftViewMode = .always
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        
        let searchImageContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 28, height: 16)))
        let searchImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: 16, height: 16)))
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.image = UIImage(named: "searchImage")
        searchImageContainerView.addSubview(searchImageView)
        searchTextField.leftView = searchImageContainerView
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 20
        tableView.allowsMultipleSelection = true
        tableView.keyboardDismissMode = .interactive
    }
    
    private func updateAddButtonTitle() {
        var buttonText = ""
        if selectedExercises.count > 0 {
            buttonText = selectedExercises.count > 0 ? "Add (\(selectedExercises.count))" : "Add"
            
            addButton.isUserInteractionEnabled = true
            addButton.alpha = 1
        } else {
            buttonText = selectedExercises.count > 0 ? "Add (\(selectedExercises.count))" : "Add"
            
            addButton.isUserInteractionEnabled = false
            addButton.alpha = 0.3
        }
        addButton.setTitle(buttonText, for: .normal)
    }
    
    @objc private func navBarButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Cancel button tapped
            break
        case 1: // Add button tapped
            workoutListDelegate?.updateWorkoutList(selectedExercises)
        default:
            break
        }
        dimmingViewDelegate?.animateDimmingView(type: .brighten)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let changedText = textField.text {
            if changedText.count == 0 {
                searchedTextArray = textArray
            } else {
                searchedTextArray = textArray.filter({ $0.lowercased().contains(changedText.lowercased()) })
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func createExerciseButtonTapped(_ sender: Any) {
        if sender is UIButton {
            print(#function)
        }
    }
}

extension AddExerciseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTextArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = searchedTextArray[indexPath.row]
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.darkGray : UIColor.lightGray
        
        return cell
    }
}

extension AddExerciseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExercises.append(textArray[indexPath.row])
        
        updateAddButtonTitle()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath),
            let name = cell.textLabel?.text,
            name.count > 0,
            let index = selectedExercises.firstIndex(of: name) else {
            return
        }
        selectedExercises.remove(at: index)
        
        updateAddButtonTitle()
    }
}
