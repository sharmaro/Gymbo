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
    @IBOutlet private weak var addExerciseButton: CustomButton!

    class var id: String {
        return String(describing: self)
    }

    private var selectedExercises = [ExerciseText]()
    private var exerciseDataModel = ExerciseDataModel.shared

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

        static let title = "Add Exercise"
    }
}

// MARK: - UIViewController Var/Funcs
extension AddExerciseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSearchTextField()
        setupTableView()
        setupAddExerciseButton()
    }
}

// MARK: - Funcs
extension AddExerciseViewController {
    private func setupNavigationBar() {
        title = Constants.title
        navigationController?.navigationBar.prefersLargeTitles = false
        if !hideBarButtonItems {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(createExerciseButtonTapped))
        }
    }

    private func setupSearchTextField() {
        searchTextField.layer.cornerRadius = 10
        searchTextField.layer.borderWidth = 1
        searchTextField.layer.borderColor = UIColor.black.cgColor
        searchTextField.borderStyle = .none
        searchTextField.leftViewMode = .always
        searchTextField.returnKeyType = .done
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

    private func setupAddExerciseButton() {
        addExerciseButton.title = "Add"
        addExerciseButton.titleLabel?.textAlignment = .center
        addExerciseButton.add(backgroundColor: .systemBlue)
        addExerciseButton.addCornerRadius()
        addExerciseButton.makeUninteractable()
    }

    private func saveExerciseInfo() {
        // Get exercise info from the selected exercises
        guard let indexPaths = tableView.indexPathsForSelectedRows else {
            return
        }

        var selectedExercises = [ExerciseText]()
        for indexPath in indexPaths {
            guard indexPath.row < tableView.numberOfRows(inSection: indexPath.section),
                let group = exerciseDataModel.exerciseGroup(for: indexPath.section) else {
                break
            }
            let exerciseText = exerciseDataModel.exerciseText(for: group, for: indexPath.row)
            selectedExercises.append(exerciseText)
        }
        exerciseListDelegate?.updateExerciseList(selectedExercises)
    }

    private func updateAddButtonTitle() {
        var title = ""
        let isEnabled: Bool

        if let indexPaths = tableView.indexPathsForSelectedRows, indexPaths.count > 0 {
            title = "Add (\(indexPaths.count))"
            isEnabled = true
        } else {
            title = "Add"
            isEnabled = false
        }
        isEnabled ? addExerciseButton.makeInteractable() : addExerciseButton.makeUninteractable()
        addExerciseButton.title = title
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func createExerciseButtonTapped() {
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

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "\n" {
            textField.resignFirstResponder()
        }

        guard let filter = textField.text?.lowercased(),
            filter.count > 0 else {
                exerciseDataModel.removeSearchedResults()
                tableView.reloadData()
                return
        }

        exerciseDataModel.filterResults(filter: filter)
        tableView.reloadData()
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        saveExerciseInfo()
        if hideBarButtonItems {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension AddExerciseViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return exerciseDataModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell,
            let group = exerciseDataModel.exerciseGroup(for: indexPath.section) else {
            fatalError("Could not dequeue cell with identifier `\(ExerciseTableViewCell.reuseIdentifier)`.")
        }

        let exerciseTableViewCellModel = exerciseDataModel.exerciseTableViewCellModel(for: group, for: indexPath.row)
        cell.configure(dataModel: exerciseTableViewCellModel)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension AddExerciseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let exerciseGroup = exerciseDataModel.exerciseGroup(for: section) else {
            fatalError("exerciseDataModel.exerciseGroup is nil ")
        }
        let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: tableView.bounds.width, height: Constants.headerHeight)))
        containerView.backgroundColor = tableView.numberOfRows(inSection: section) > 0 ? .black : .darkGray

        let titleLabel = UILabel()
        titleLabel.text = exerciseGroup
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
    func addCreatedExercise(exerciseGroup: String, exerciseText: ExerciseText) {
        exerciseDataModel.addCreatedExercise(exerciseGroup: exerciseGroup, exerciseText: exerciseText)
        tableView.reloadData()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension AddExerciseViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
