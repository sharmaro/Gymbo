//
//  ExercisePreviewTVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/2/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisePreviewTVC: UITableViewController {
    private let editDisclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.editDisclaimerText
        label.textAlignment = .center
        label.font = UIFont.medium.light
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .dynamicWhite
        return label
    }()

    private let editButton: CustomButton = {
        let button = CustomButton()
        button.title = "Edit"
        button.titleLabel?.font = .normal
        button.set(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private var isExerciseUserMade: Bool {
        customDataSource?.exercise.isUserMade ?? false
    }

    private let exercisesTVDS: ExercisesTVDS?

    var customDataSource: ExercisePreviewTVDS?
    var customDelegate: ExercisePreviewTVD?

    init(exercisesTVDS: ExercisesTVDS?) {
        self.exercisesTVDS = exercisesTVDS
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not using storyboards")
    }
}

// MARK: - Structs/Enums
private extension ExercisePreviewTVC {
    struct Constants {
        static let editDisclaimerText = "*Only exercises made by you can be edited."

        static let viewToUseHeight = CGFloat(45)
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisePreviewTVC {
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
extension ExercisePreviewTVC: ViewAdding {
    func setupNavigationBar() {
        title = "Exercise"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }

    func addViews() {
        if isExerciseUserMade {
            view.add(subviews: [editButton])
        } else {
            view.add(subviews: [editDisclaimerLabel])
        }
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(TwoLabelsTVCell.self,
                           forCellReuseIdentifier: TwoLabelsTVCell.reuseIdentifier)
        tableView.register(SwipableImageVTVCell.self,
                           forCellReuseIdentifier: SwipableImageVTVCell.reuseIdentifier)
        tableView.register(LabelTVCell.self,
                           forCellReuseIdentifier: LabelTVCell.reuseIdentifier)
        let spacing: CGFloat = isExerciseUserMade ? 15 : 0
        tableView.contentInset.bottom = Constants.viewToUseHeight + spacing

        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        [view, tableView, editDisclaimerLabel].forEach { $0.backgroundColor = .dynamicWhite }
        editDisclaimerLabel.textColor = UIColor.dynamicBlack.withAlphaComponent(0.5)
    }

    func addConstraints() {
        let viewToUse = isExerciseUserMade ? editButton : editDisclaimerLabel
        let bottomSpacing: CGFloat = isExerciseUserMade ? -15 : 0

        NSLayoutConstraint.activate([
            viewToUse.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            viewToUse.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            viewToUse.safeAreaLayoutGuide.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: bottomSpacing),
            viewToUse.heightAnchor.constraint(equalToConstant: Constants.viewToUseHeight)
        ])
    }
}

// MARK: - Funcs
extension ExercisePreviewTVC {
    private func refreshTitleLabels() {
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }

    @objc private func closeButtonTapped(sender: Any) {
        Haptic.sendSelectionFeedback()
        dismiss(animated: true)
    }

    @objc private func editButtonTapped(sender: Any) {
        Haptic.sendSelectionFeedback()
        let exercise = customDataSource?.exercise ?? Exercise()
        let createEditExerciseTVC = VCFactory
            .makeCreateEditExerciseTVC(exercise: exercise,
                                       state: .edit,
                                       delegate: self)
        let modalNC = VCFactory.makeMainNC(rootVC: createEditExerciseTVC,
                                       transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)
    }
}

// MARK: - ExerciseDataModelDelegate
extension ExercisePreviewTVC: ExerciseDataModelDelegate {
    func update(_ currentName: String,
                exercise: Exercise,
                completion: @escaping (Result<Any?, DataError>) -> Void) {
        exercisesTVDS?.update(currentName,
                              exercise: exercise) { [weak self] result in
            switch result {
            case .success(let value):
                completion(.success(value))
                self?.customDataSource?.exercise = exercise
                self?.refreshTitleLabels()
                self?.tableView.reloadData()

                // Updates ExercisesTVC
                NotificationCenter.default.post(name: .updateExercisesUI, object: nil)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
