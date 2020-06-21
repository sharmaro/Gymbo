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
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.addCorner(style: .medium)
        return view
    }()

    private let closeButton: CustomButton = {
        let button = CustomButton()
        let closeImage = UIImage(named: "close")
        button.setImage(closeImage, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.add(backgroundColor: .lightGray)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
        label.numberOfLines = 0
        label.backgroundColor = .white
        return label
    }()

    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .normal
        label.textColor = .systemGray
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .white
        return label
    }()

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
        label.font = UIFont.small.light
        label.textColor = UIColor.black.withAlphaComponent(0.5)
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

    private var exercise: Exercise

    private let tableData: [TableRow] = [.imagesTitle, .images, .instructionsTitle,
                                         .instructions, .tipsTitle, .tips]

    weak var dimmedViewDelegate: DimmedViewDelegate?

    init(exercise: Exercise) {
        self.exercise = exercise

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.exercise = Exercise()

        super.init(coder: coder)
    }
}

// MARK: - Structs/Enums
private extension ExercisePreviewViewController {
    struct Constants {
        static let swipableImageViewTableViewCellHeight = CGFloat(200)

        static let noImagesText = "No images\n"
        static let noInstructionsText = "No instructions\n"
        static let noTipsText = "No tips\n"
        static let editDisclaimerText = "*Only exercises made by you can be edited."
    }

    enum TableRow: String {
        case imagesTitle = "Images"
        case images
        case instructionsTitle = "Instructions"
        case instructions
        case tipsTitle = "Tips"
        case tips
    }
}

// MARK: - ViewAdding
extension ExercisePreviewViewController: ViewAdding {
    func addViews() {
        view.add(subviews: [containerView])
        containerView.add(subviews: [closeButton, titleLabel, subTitleLabel, tableView])
        if exercise.isUserMade {
            containerView.add(subviews: [editButton])
        } else {
            containerView.add(subviews: [editDisclaimerLabel])
        }
    }

    func setupViews() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        titleLabel.text = exercise.name
        subTitleLabel.text = exercise.groups

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SwipableImageViewTableViewCell.self,
                           forCellReuseIdentifier: SwipableImageViewTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self,
                           forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self,
                           forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)

        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            containerView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            containerView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7)
        ])

        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            closeButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalTo: closeButton.widthAnchor)
        ])
        closeButton.layoutIfNeeded()
        closeButton.addCorner(style: .circle(length: closeButton.frame.height))

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: subTitleLabel.topAnchor, constant: -2)
        ])

        NSLayoutConstraint.activate([
            subTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            subTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            subTitleLabel.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -10)
        ])

        let viewToUse = exercise.isUserMade ? editButton : editDisclaimerLabel
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: viewToUse.topAnchor)
        ])

        NSLayoutConstraint.activate([
            viewToUse.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            viewToUse.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            viewToUse.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            viewToUse.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - UIViewController Var/Funcs
extension ExercisePreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()
    }
}

// MARK: - Funcs
extension ExercisePreviewViewController {
    private func refreshTitleLabels() {
        titleLabel.text = exercise.name
        subTitleLabel.text = exercise.groups
    }

    @objc private func closeButtonTapped(sender: Any) {
        dismiss(animated: true)
        dimmedViewDelegate?.removeView()
    }

    @objc private func editButtonTapped(sender: Any) {
        let createEditExerciseTableViewController = CreateEditExerciseTableViewController()
        createEditExerciseTableViewController.exercise = exercise
        createEditExerciseTableViewController.exerciseState = .edit
        createEditExerciseTableViewController.exerciseDataModelDelegate = self

        let modalNavigationController = UINavigationController(rootViewController: createEditExerciseTableViewController)
        modalNavigationController.modalPresentationStyle = .custom
        modalNavigationController.modalTransitionStyle = .crossDissolve
        modalNavigationController.transitioningDelegate = self
        present(modalNavigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ExercisePreviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let tableItem = tableData[indexPath.row]

        switch tableItem {
        case .imagesTitle, .instructionsTitle, .tipsTitle:
            guard let labelTableViewCell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.reuseIdentifier, for: indexPath) as? LabelTableViewCell else {
                fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
            }

            labelTableViewCell.configure(text: tableItem.rawValue, font: UIFont.large.medium)
            cell = labelTableViewCell
        case .images:
            if exercise.imagesData.isEmpty {
                guard let labelTableViewCell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.reuseIdentifier, for: indexPath) as? LabelTableViewCell else {
                    fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
                }

                labelTableViewCell.configure(text: Constants.noImagesText)
                cell = labelTableViewCell
            } else {
                guard let swipableImageViewCell = tableView.dequeueReusableCell(withIdentifier: SwipableImageViewTableViewCell.reuseIdentifier, for: indexPath) as? SwipableImageViewTableViewCell else {
                    fatalError("Could not dequeue \(SwipableImageViewTableViewCell.reuseIdentifier)")
                }

                let imagesDataArray = Array(exercise.imagesData)
                swipableImageViewCell.configure(imagesData: imagesDataArray)
                cell = swipableImageViewCell
            }
        case .instructions, .tips:
            guard let labelTableViewCell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.reuseIdentifier, for: indexPath) as? LabelTableViewCell else {
                fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
            }

            let text = tableItem == .instructions ? exercise.instructions : exercise.tips
            let emptyText = tableItem == .instructions ? Constants.noInstructionsText : Constants.noTipsText
            labelTableViewCell.configure(text: text ?? emptyText)
            cell = labelTableViewCell
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ExercisePreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableItem = tableData[indexPath.row]
        switch tableItem {
        case .images:
            return exercise.imagesData.isEmpty ? UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableItem = tableData[indexPath.row]
        switch tableItem {
        case .images:
            return exercise.imagesData.isEmpty ? UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - ExerciseDataModelDelegate
extension ExercisePreviewViewController: ExerciseDataModelDelegate {
    func update(_ currentName: String, exercise: Exercise, success: @escaping (() -> Void), fail: @escaping (() -> Void)) {
        ExerciseDataModel.shared.update(currentName, exercise: exercise, success: { [weak self] in
            DispatchQueue.main.async {
                success()
                self?.exercise = exercise
                self?.refreshTitleLabels()
                self?.tableView.reloadData()
                NotificationCenter.default.post(name: .updateExercisesUI, object: nil)
            }
        }, fail: fail)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension ExercisePreviewViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let modalPresentationController = ModalPresentationController(presentedViewController: presented, presenting: presenting)
        modalPresentationController.showDimmingView = false
        modalPresentationController.customBounds = CustomBounds(horizontalPadding: 20, percentHeight: 0.7)
        
        return modalPresentationController
    }
}
