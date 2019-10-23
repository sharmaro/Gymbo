//
//  AddExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

struct ExerciseText: Codable {
    var exerciseName: String?
    var exerciseMuscles: String?
    let isUserMade: Bool
}

class AddExerciseViewController: UIViewController {
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var customNavigationItem: UINavigationItem!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createExerciseButton: CustomButton!

    private lazy var cancelButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Cancel", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.tag = 0
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private lazy var addButton: UIButton = {
        let button = CustomButton(frame: CGRect(origin: .zero, size: Constants.navBarButtonSize))
        button.setTitle("Add", for: .normal)
        button.titleFontSize = 12
        button.addCornerRadius()
        button.alpha = Constants.inactiveAlpha
        button.tag = 1
        button.addTarget(self, action: #selector(navBarButtonPressed), for: .touchUpInside)
        return button
    }()

    private let exerciseGroups = ["Abs", "Arms", "Back", "Buttocks", "Chest",
                                 "Hips", "Legs", "Shoulders", "Extra Workouts"]
    private var exerciseInfoDict = [String: [ExerciseText]]()
    // Used to store the filtered results based on user search
    private var searchResultsExerciseInfoDict = [String: [ExerciseText]]()

    private var selectedExercises = [ExerciseText]()

    weak var workoutListDelegate: WorkoutListDelegate?

    private struct Constants {
        static let navBarButtonSize: CGSize = CGSize(width: 60, height: 20)

        static let workoutCellHeight: CGFloat = 60

        static let activeAlpha: CGFloat = 1.0
        static let inactiveAlpha: CGFloat = 0.3

        static let EXERCISE_INFO_KEY = "exerciseInfoKey"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupExerciseInfo()
        setupSearchTextField()
        setupTableView()
        setupExerciseButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveExerciseInfo()
    }

    private func setupNavigationBar() {
        navigationBar.prefersLargeTitles = false
        customNavigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        customNavigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        addButton.isEnabled = false // Doesn't work if you disable it in the lazy variable
    }

    private func setupExerciseInfo() {
        if let exerciseDict = loadExerciseInfo() {
            exerciseInfoDict = exerciseDict
        } else {
            for group in exerciseGroups {
                do {
                    guard let filePath = Bundle.main.path(forResource: group, ofType: "txt"),
                        let content = try? String(contentsOfFile: filePath) else {
                            print("Error while opening file: \(group).txt.")
                            return
                    }
                    let workouts = content.components(separatedBy: "\n")
                    for workout in workouts {
                        // Prevents reading the empty line at EOF
                        if workout.count > 0 {
                            let workoutSplitList = workout.split(separator: ":")
                            let exerciseName = String(workoutSplitList[0])
                            let exerciseMuscles =  String(workoutSplitList[1])
                            let exerciseText = ExerciseText(exerciseName: exerciseName,
                                                            exerciseMuscles: exerciseMuscles,
                                                            isUserMade: false)
                            if exerciseInfoDict[group] == nil {
                                exerciseInfoDict[group] = [exerciseText]
                            } else {
                                exerciseInfoDict[group]?.append(exerciseText)
                            }
                        }
                    }
                }
            }
        }
        saveExerciseInfo()
        tableView.reloadData()
    }

    private func setupSearchTextField() {
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.borderStyle = .none
        searchTextField.leftViewMode = .always
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        let searchImageContainerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 28, height: 16)))
        let searchImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 10, y: 0), size: CGSize(width: 16, height: 16)))
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.image = UIImage(named: "searchImage")
        searchImageContainerView.addSubview(searchImageView)
        searchTextField.leftView = searchImageContainerView
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 20
        tableView.layer.borderWidth = 1
        tableView.layer.borderColor = UIColor.black.cgColor
        tableView.allowsMultipleSelection = true
        tableView.keyboardDismissMode = .interactive
        tableView.register(WorkoutTableViewCell.nib, forCellReuseIdentifier: WorkoutTableViewCell.reuseIdentifier)
    }

    private func setupExerciseButton() {
        createExerciseButton.setTitle("+ Create New Exercise", for: .normal)
        createExerciseButton.titleLabel?.textAlignment = .center
        createExerciseButton.addCornerRadius()
    }

    private func loadExerciseInfo() -> [String: [ExerciseText]]? {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        guard let data = defaults.data(forKey: Constants.EXERCISE_INFO_KEY),
            let exerciseDict = try? decoder.decode(Dictionary<String, [ExerciseText]>.self, from: data) else {
            return nil
        }
        return exerciseDict
    }

    private func saveExerciseInfo() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode(exerciseInfoDict) {
            defaults.set(encodedData, forKey: Constants.EXERCISE_INFO_KEY)
        }
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
            if let indexPaths = tableView.indexPathsForSelectedRows {
                var selectedExercises = [ExerciseText]()
                for indexPath in indexPaths {
                    guard indexPath.row < tableView.numberOfRows(inSection: indexPath.section) else {
                        break
                    }
                    let dictToUse = searchResultsExerciseInfoDict.count > 0 ? searchResultsExerciseInfoDict : exerciseInfoDict
                    if let exerciseText = dictToUse[exerciseGroups[indexPath.section]]?[indexPath.row] {
                        selectedExercises.append(exerciseText)
                    }
                }
                workoutListDelegate?.updateWorkoutList(selectedExercises)
            }
        default:
            fatalError("Unrecognized navigation bar button pressed")
        }
        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let changedText = textField.text,
            changedText.count > 0 else {
                searchResultsExerciseInfoDict.removeAll()
                tableView.reloadData()
                return
        }

        exerciseInfoDict.forEach {
            searchResultsExerciseInfoDict[$0.key] = $0.value.filter {
                ($0.exerciseName ?? "").lowercased().contains(changedText.lowercased())
            }
        }
        tableView.reloadData()
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
        if searchResultsExerciseInfoDict.count > 0 {
            return searchResultsExerciseInfoDict.count
        }
        return exerciseInfoDict.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let exerciseGroup = exerciseGroups[section]
        if searchResultsExerciseInfoDict.count > 0 {
            return searchResultsExerciseInfoDict[exerciseGroup]?.count ?? 0
        }

        return exerciseInfoDict[exerciseGroup]?.count ?? 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: 40)))
        titleLabel.text = exerciseGroups[section]
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.backgroundColor = tableView.numberOfRows(inSection: section) > 0 ? .black : .darkGray
        return titleLabel
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.workoutCellHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WorkoutTableViewCell.reuseIdentifier, for: indexPath) as? WorkoutTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(WorkoutTableViewCell.reuseIdentifier)`.")
        }
        let dictToUse = searchResultsExerciseInfoDict.count > 0 ? searchResultsExerciseInfoDict : exerciseInfoDict
        let exerciseGroup = exerciseGroups[indexPath.section]

        cell.exerciseNameLabel.text = dictToUse[exerciseGroup]?[indexPath.row].exerciseName
        cell.exerciseMusclesLabel.text = dictToUse[exerciseGroup]?[indexPath.row].exerciseMuscles

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
    func addExercise(exerciseGroup: String, exerciseText: ExerciseText) {
        if exerciseInfoDict[exerciseGroup] == nil {
            exerciseInfoDict[exerciseGroup] = [exerciseText]
        } else {
            exerciseInfoDict[exerciseGroup]?.append(exerciseText)
            exerciseInfoDict[exerciseGroup]?.sort {
                return ($0.exerciseName ?? "").lowercased() < ($1.exerciseName ?? "").lowercased()
            }
        }
        tableView.reloadData()
    }
}

extension AddExerciseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
