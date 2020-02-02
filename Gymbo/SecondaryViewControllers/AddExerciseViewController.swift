//
//  AddExerciseViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 8/1/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

protocol ExerciseListDelegate: class {
    func updateExerciseList(_ exerciseTextList: [ExerciseText])
}

struct ExerciseText: Codable {
    var exerciseName: String?
    var exerciseMuscles: String?
    let isUserMade: Bool
}

class AddExerciseViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var createExerciseButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private let exerciseGroups = ["Abs", "Arms", "Back", "Buttocks", "Chest",
                                 "Hips", "Legs", "Shoulders", "Extra Exercises"]
    private var exerciseInfoDict = [String: [ExerciseText]]()
    // Used to store the filtered results based on user search
    private var searchResultsExerciseInfoDict = [String: [ExerciseText]]()

    private var selectedExercises = [ExerciseText]()

    var hideBarButtonItems = false

    weak var exerciseListDelegate: ExerciseListDelegate?
}

// MARK: - Structs/Enums
private extension AddExerciseViewController {
    struct Constants {
        static let navBarButtonSize = CGSize(width: 80, height: 30)

        static let exerciseCellHeight = CGFloat(62)
        static let headerHeight = CGFloat(30)
        static let headerFontSize = CGFloat(20)
        static let activeAlpha = CGFloat(1.0)
        static let inactiveAlpha = CGFloat(0.3)

        static let EXERCISE_INFO_KEY = "exerciseInfoKey"
        static let title = "Add Exercise"
    }
}

// MARK: - UIViewController Funcs
extension AddExerciseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupExerciseInfo()
        setupSearchTextField()
        setupTableView()
        setupCreatExerciseButton()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if hideBarButtonItems {
            saveExerciseInfo()
        }
    }
}

// MARK: - Funcs
extension AddExerciseViewController {
    private func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = false
        if !hideBarButtonItems {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
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
                    let exercises = content.components(separatedBy: "\n")
                    for exercise in exercises {
                        // Prevents reading the empty line at EOF
                        if exercise.count > 0 {
                            let exerciseSplitList = exercise.split(separator: ":")
                            let exerciseName = String(exerciseSplitList[0])
                            let exerciseMuscles =  String(exerciseSplitList[1])
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
        searchImageView.image = UIImage(named: "search")
        searchImageContainerView.addSubview(searchImageView)
        searchTextField.leftView = searchImageContainerView
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        tableView.allowsMultipleSelection = true
        tableView.keyboardDismissMode = .interactive
        tableView.register(ExerciseTableViewCell.nib,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)
    }

    private func setupCreatExerciseButton() {
        createExerciseButton.title = "Create New Exercise"
        createExerciseButton.titleLabel?.textAlignment = .center
        createExerciseButton.add(backgroundColor: .systemBlue)
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
        // Get exercise info from the selected exercises
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }

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
        exerciseListDelegate?.updateExerciseList(selectedExercises)

        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        if let encodedData = try? encoder.encode(exerciseInfoDict) {
            defaults.set(encodedData, forKey: Constants.EXERCISE_INFO_KEY)
        }
    }

    private func updateAddButtonTitle() {
        guard !hideBarButtonItems else {
            return
        }

        var title = ""
        let isEnabled: Bool
        let alpha: CGFloat
        if let indexPaths = tableView.indexPathsForSelectedRows, indexPaths.count > 0 {
            title = "Add (\(indexPaths.count))"
            isEnabled = true
            alpha = Constants.activeAlpha
        } else {
            title = "Add"
            isEnabled = false
            alpha = Constants.inactiveAlpha
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
        navigationItem.rightBarButtonItem?.customView?.alpha = alpha
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func addButtonTapped() {
        saveExerciseInfo()
        dismiss(animated: true, completion: nil)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let changedText = textField.text?.lowercased(),
            changedText.count > 0 else {
                searchResultsExerciseInfoDict.removeAll()
                tableView.reloadData()
                return
        }

        exerciseInfoDict.forEach {
            searchResultsExerciseInfoDict[$0.key] = $0.value.filter {
                ($0.exerciseName ?? "").lowercased().contains(changedText)
            }
        }
        tableView.reloadData()
    }

    @IBAction func createExerciseButtonTapped(_ sender: Any) {
        guard let createExerciseVC = storyboard?.instantiateViewController(withIdentifier: CreateExerciseViewController.id) as? CreateExerciseViewController else {
            return
        }

        let modalNavigationController = UINavigationController(rootViewController: createExerciseVC)
        if #available(iOS 13.0, *) {
            // No op
        } else {
            modalNavigationController.modalPresentationStyle = .custom
            modalNavigationController.transitioningDelegate = self
        }

        createExerciseVC.createExerciseDelegate = self
        present(modalNavigationController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
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

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell else {
            fatalError("Could not dequeue cell with identifier `\(ExerciseTableViewCell.reuseIdentifier)`.")
        }
        let dictToUse = searchResultsExerciseInfoDict.count > 0 ? searchResultsExerciseInfoDict : exerciseInfoDict
        let exerciseGroup = exerciseGroups[indexPath.section]

        var dataModel = ExerciseTableViewCellModel()
        dataModel.name = dictToUse[exerciseGroup]?[indexPath.row].exerciseName
        dataModel.muscles = dictToUse[exerciseGroup]?[indexPath.row].exerciseMuscles

        cell.configure(dataModel: dataModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddExerciseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: Constants.headerHeight)))
        containerView.backgroundColor = tableView.numberOfRows(inSection: section) > 0 ? .black : .darkGray

        let titleLabel = UILabel()
        titleLabel.text = exerciseGroups[section]
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: Constants.headerFontSize)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        titleLabel.leadingAndTrailingTo(superView: containerView, leading: 10, trailing: 0)

        return containerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.exerciseCellHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        updateAddButtonTitle()
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateAddButtonTitle()
    }
}

// MARK: - CreateExerciseDelegate
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

// MARK: - UIViewControllerTransitioningDelegate
extension AddExerciseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
