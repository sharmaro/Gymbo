//
//  ExercisePreviewViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/2/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisePreviewViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let editDisclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.editDisclaimerText
        label.textAlignment = .center
        label.font = UIFont.medium.light
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    private let editButton: CustomButton = {
        let button = CustomButton()
        button.title = "Edit"
        button.titleLabel?.font = .normal
        button.add(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private let exerciseDataModel = ExerciseDataModel()
    private var exercisePreviewDataModel = ExercisePreviewDataModel()

    init(exercise: Exercise) {
        self.exercisePreviewDataModel.exercise = exercise

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.exercisePreviewDataModel.exercise = Exercise()

        super.init(coder: coder)
    }
}

// MARK: - Structs/Enums
private extension ExercisePreviewViewController {
    struct Constants {
        static let title = "Exercise"
        static let editDisclaimerText = "*Only exercises made by you can be edited."
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisePreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension ExercisePreviewViewController: ViewAdding {
    func setupNavigationBar() {
        navigationItem.title = Constants.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView])
        if exercisePreviewDataModel.exercise.isUserMade {
            view.add(subviews: [editButton])
        } else {
            view.add(subviews: [editDisclaimerLabel])
        }
    }

    func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TwoLabelsTableViewCell.self,
                           forCellReuseIdentifier: TwoLabelsTableViewCell.reuseIdentifier)
        tableView.register(SwipableImageViewTableViewCell.self,
                           forCellReuseIdentifier: SwipableImageViewTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self,
                           forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)

        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .mainWhite }
        editDisclaimerLabel.textColor = UIColor.mainBlack.withAlphaComponent(0.5)
    }

    func addConstraints() {
        let viewToUse = exercisePreviewDataModel.exercise.isUserMade ? editButton : editDisclaimerLabel
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: viewToUse.topAnchor),

            viewToUse.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            viewToUse.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            viewToUse.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -15),
            viewToUse.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - Funcs
extension ExercisePreviewViewController {
    private func refreshTitleLabels() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

    @objc private func closeButtonTapped(sender: Any) {
        dismiss(animated: true)
    }

    @objc private func editButtonTapped(sender: Any) {
        let createEditExerciseTableViewController = CreateEditExerciseTableViewController()
        createEditExerciseTableViewController.exercise = exercisePreviewDataModel.exercise
        createEditExerciseTableViewController.exerciseState = .edit
        createEditExerciseTableViewController.exerciseDataModelDelegate = self

        let modalNavigationController = UINavigationController(
            rootViewController: createEditExerciseTableViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.modalTransitionStyle = .crossDissolve
        modalNavigationController.transitioningDelegate = self
        present(modalNavigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ExercisePreviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exercisePreviewDataModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        exercisePreviewDataModel.cellForRow(in: tableView, at: indexPath)
    }
}

// MARK: - UITableViewDelegate
extension ExercisePreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        exercisePreviewDataModel.heightForRow(at: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        exercisePreviewDataModel.heightForRow(at: indexPath)
    }
}

// MARK: - ExerciseDataModelDelegate
extension ExercisePreviewViewController: ExerciseDataModelDelegate {
    func update(_ currentName: String,
                exercise: Exercise,
                success: @escaping (() -> Void),
                fail: @escaping (() -> Void)) {
        exerciseDataModel.update(currentName, exercise: exercise, success: { [weak self] in
            DispatchQueue.main.async {
                success()
                self?.exercisePreviewDataModel.exercise = exercise
                self?.refreshTitleLabels()
                self?.tableView.reloadData()
                NotificationCenter.default.post(name: .updateExercisesUI, object: nil)
            }
        }, fail: fail)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ExercisePreviewViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(
            presentedViewController: presented,
            presenting: presenting)
        modalPresentationController.showDimmingView = false
        modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.7)
        return modalPresentationController
    }
}
