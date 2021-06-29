//
//  ExercisePreviewVC.swift
//  Gymbo
//
//  Created by Rohan Sharma on 5/2/20.
//  Copyright © 2020 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class ExercisePreviewVC: UIViewController {
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        return tableView
    }()

    private let editDisclaimerLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.editDisclaimerText
        label.textAlignment = .center
        label.font = UIFont.medium.light
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .primaryBackground
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
private extension ExercisePreviewVC {
    enum Constants {
        static let editDisclaimerText = "*Only exercises made by you can be edited."

        static let viewToUseHeight = CGFloat(45)
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisePreviewVC {
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
extension ExercisePreviewVC: ViewAdding {
    func setupNavigationBar() {
        title = "Exercise"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(closeButtonTapped))
    }

    func addViews() {
        view.add(subviews: [tableView])
        if isExerciseUserMade {
            view.add(subviews: [editButton])
        } else {
            view.add(subviews: [editDisclaimerLabel])
        }
    }

    func setupViews() {
        tableView.dataSource = customDataSource
        tableView.delegate = customDelegate

        tableView.register(ExercisesHFV.self,
                           forHeaderFooterViewReuseIdentifier: ExercisesHFV.reuseIdentifier)
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
        [view, tableView, editDisclaimerLabel].forEach { $0.backgroundColor = .primaryBackground }
        editDisclaimerLabel.textColor = .secondaryText
    }

    func addConstraints() {
        tableView.autoPinSafeEdges(to: view)

        let viewToUse = isExerciseUserMade ? editButton : editDisclaimerLabel
        let bottomSpacing: CGFloat = isExerciseUserMade ? -15 : 0
        NSLayoutConstraint.activate([
            viewToUse.safeLeading.constraint(
                equalTo: view.safeLeading,
                constant: 20),
            viewToUse.safeTrailing.constraint(
                equalTo: view.safeTrailing,
                constant: -20),
            viewToUse.safeBottom.constraint(
                equalTo: view.safeBottom,
                constant: bottomSpacing),
            viewToUse.height.constraint(equalToConstant: Constants.viewToUseHeight)
        ])
    }
}

// MARK: - Funcs
extension ExercisePreviewVC {
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
        let createEditExerciseVC = VCFactory
            .makeCreateEditExerciseVC(exercise: exercise,
                                      state: .edit,
                                      delegate: self)
        let modalNC = VCFactory.makeMainNC(rootVC: createEditExerciseVC,
                                       transitioningDelegate: self)
        navigationController?.present(modalNC, animated: true)
    }
}

// MARK: - ExerciseDataModelDelegate
extension ExercisePreviewVC: ExerciseDataModelDelegate {
    func update(_ currentName: String,
                exercise: Exercise,
                completion: @escaping (Result<Any?, DataError>) -> Void) {
        exercisesTVDS?.update(currentName,
                              exercise: exercise) { [weak self] result in
            switch result {
            case .success(let value):
                completion(.success(value))
                self?.customDataSource?.exercise = exercise
                self?.customDelegate?.exercise = exercise
                self?.refreshTitleLabels()
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }

                // Updates ExercisesVC
                NotificationCenter.default.post(name: .updateExercisesUI, object: nil)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
