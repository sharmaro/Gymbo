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
    @IBOutlet weak var addExerciseButton: CustomButton!
    
    private lazy var doneButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 45, height: 20)))
        button.setTitle("Done", for: .normal)
        button.titleFontSize = 12
        button.borderWidth = 1
        button.borderColor = UIColor.black
        button.cornerRadius = 10
        button.addTarget(self, action: #selector(doneButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    weak var dimmingViewDelegate: DimmingViewDelegate?
    
    private var textArray =
        ["Hello", "This is", "a test", "Yummy", "Apple", "Carrot", "Orange", "Red", "Chocolate",
         "Hello", "This is", "a test", "Yummy", "Apple", "Carrot", "Orange", "Red", "Chocolate",
         "Hello", "This is", "a test", "Yummy", "Apple", "Carrot", "Orange", "Red", "Chocolate",
         "Hello", "This is", "a test", "Yummy", "Apple", "Carrot", "Orange", "Red", "Chocolate"]
    private var searchedTextArray = [String]()
    private var sortedArray = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupSearchTextField()
        setupTableView()
        setupAddExerciseButton()
        
        searchedTextArray = textArray
    }
    
    private func setupView() {
        navigationBar.prefersLargeTitles = false
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 20
    }
    
    private func setupSearchTextField() {
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.leftViewMode = .always
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_ :)), for: .editingChanged)
        
        let searchImageContainerView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 26, height: 16)))
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
    }
    
    private func setupAddExerciseButton() {
        addExerciseButton.cornerRadius = 10
        addExerciseButton.borderWidth = 1
        addExerciseButton.borderColor = .black
    }
    
    @objc private func doneButtonPressed(_ sender: UIButton) {
        dimmingViewDelegate?.animateDimmingView(type: .hide)
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
        print("Selected cell at index path: \(indexPath).")
    }
}
