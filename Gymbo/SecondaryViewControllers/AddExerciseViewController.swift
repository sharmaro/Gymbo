//
//  AddExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct ExerciseText {
    var exerciseName: String?
    var muscleGroups: String?
}

class AddExerciseViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createExerciseButton: CustomButton!

    private lazy var cancelButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Constants.navBarButtonSize))
        button.setTitle("Cancel", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var addButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: Constants.navBarButtonSize))
        button.setTitle("Add", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.alpha = Constants.inactiveAlpha
        button.tag = 1
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private var exerciseNameArray =
        ["Exercise 0", "Exercise 1", "Exercise 2", "Exercise 3", "Exercise 4", "Exercise 5", "Exercise 6", "Exercise 7",
         "Exercise 8", "Exercise 9", "Exercise 10", "Exercise 11", "Exercise 12", "Exercise 13", "Exercise 14", "Exercise 15",
         "Exercise 16", "Exercise 17", "Exercise 18", "Exercise 19", "Exercise 20", "Exercise 21", "Exercise 22", "Exercise 23"]
    private var muscleGroupArray =
        ["shoulders, traps", "biceps", "triceps", "quads", "back", "triceps", "legs", "back",
         "abs, obliques, biceps", "triceps", "quads", "calves", "legs", "back", "triceps", "calves",
         "back, biceps", "chest, triceps, biceps", "quads, triceps", "calves, biceps", "back",
         "chest,quads", "abs, triceps", "quads"]

    // For searching exercises
    private var searchedTextArray = [String]()

    private var selectedExercises = [ExerciseText]()

    weak var workoutListDelegate: WorkoutListDelegate?

    private struct Constants {
        static let navBarButtonSize: CGSize = CGSize(width: 60, height: 20)

        static let workoutCellHeight: CGFloat = 60

        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSearchTextField()
        setupTableView()

        createExerciseButton.setTitle("Create New Exercise", for: .normal)
        createExerciseButton.titleLabel?.textAlignment = .center
        createExerciseButton.addCornerRadius()

        searchedTextArray = exerciseNameArray
    }

    private func setupNavigationBar() {
        navigationBar.prefersLargeTitles = false
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        addButton.isEnabled = false // Doesn't work if you disable it in the lazy variable
    }

    private func setupSearchTextField() {
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.borderStyle = .none
        searchTextField.leftViewMode = .always
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

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
        tableView.register(WorkoutTableViewCell.nib, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
    }

    private func updateAddButtonTitle() {
        var buttonText = ""
        if let indexPaths = tableView.indexPathsForSelectedRows, indexPaths.count > 0 {
            buttonText = "Add (\(indexPaths.count))"

            addButton.isEnabled = true
            addButton.alpha = Constants.activeAlpha
        } else {
            buttonText = "Add"

            addButton.isEnabled = false
            addButton.alpha = Constants.inactiveAlpha
        }
        addButton.setTitle(buttonText, for: .normal)
    }

    @objc private func navBarButtonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 0: // Cancel button tapped
            break
        case 1: // Add button tapped
            // Get exercise info from the selected exercises
            if let indexPaths = tableView.indexPathsForSelectedRows, indexPaths.count > 0 {
                guard indexPaths.count <= tableView.numberOfRows(inSection: 0) else {
                    break
                }
                var selectedExercises = [ExerciseText]()
                for indexPath in indexPaths {
                    let exerciseName = exerciseNameArray[indexPath.row]
                    let muscleGroups = muscleGroupArray[indexPath.row]
                    let exerciseText = ExerciseText(exerciseName: exerciseName, muscleGroups: muscleGroups)
                    selectedExercises.append(exerciseText)
                }
                workoutListDelegate?.updateWorkoutList(selectedExercises)
            }
        default:
            fatalError("Unrecognized navigation bar button pressed")
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let changedText = textField.text {
            if changedText.count == 0 {
                searchedTextArray = exerciseNameArray
            } else {
                searchedTextArray = exerciseNameArray.filter({ $0.lowercased().contains(changedText.lowercased()) })
            }
            tableView.reloadData()
        }
    }

    @IBAction func createExerciseButtonTapped(_ sender: Any) {
        if sender is UIButton {
            if let createExerciseVC = storyboard?.instantiateViewController(withIdentifier: "CreateExerciseViewController") as? CreateExerciseViewController {
                if #available(iOS 13.0, *) {
                    // No op
                } else {
                    createExerciseVC.modalPresentationStyle = .custom
                    createExerciseVC.transitioningDelegate = self
                    createExerciseVC.createExerciseDelegate = self
                }
                present(createExerciseVC, animated: true, completion: nil)
            }
        }
    }
}

extension AddExerciseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.workoutCellHeight
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedTextArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(WorkoutTableViewCell.reuseIdentifier)`.")
        }
        cell.exerciseNameLabel.text = searchedTextArray[indexPath.row]
        cell.muscleGroupsLabel.text = muscleGroupArray[indexPath.row]

        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.darkGray : UIColor.lightGray

        return cell
    }
}

extension AddExerciseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateAddButtonTitle()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateAddButtonTitle()
    }
}

extension AddExerciseViewController: CreateExerciseDelegate {
    func addExercise(exercise: String, muscleGroups: String) {
        exerciseNameArray.append(exercise)
        muscleGroupArray.append(muscleGroups)
        searchedTextArray = exerciseNameArray
        tableView.reloadData()
    }
}

extension AddExerciseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
