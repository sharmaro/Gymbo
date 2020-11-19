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
    private var exercise: Exercise

    private let tableData: [TableRow] = [ .title, .imagesTitle, .images, .instructionsTitle,
                                         .instructions, .tipsTitle, .tips]

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
        static let title = "Exercise"

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
        case title
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
        if exercise.isUserMade {
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
        let viewToUse = exercise.isUserMade ? editButton : editDisclaimerLabel
        NSLayoutConstraint.activate([
            tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: viewToUse.topAnchor),

            viewToUse.safeAreaLayoutGuide.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            viewToUse.safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            viewToUse.safeAreaLayoutGuide.bottomAnchor.constraint(
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

    private func getTwoLabelsTableViewCell(for indexPath: IndexPath) -> TwoLabelsTableViewCell {
        guard let twoLabelsTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: TwoLabelsTableViewCell.reuseIdentifier,
            for: indexPath) as? TwoLabelsTableViewCell else {
            fatalError("Could not dequeue \(TwoLabelsTableViewCell.reuseIdentifier)")
        }

        twoLabelsTableViewCell.configure(topText: exercise.name ?? "", bottomText: exercise.groups ?? "")
        return twoLabelsTableViewCell
    }

    private func getLabelTableViewCell(for indexPath: IndexPath,
                                       text: String,
                                       font: UIFont = .normal) -> LabelTableViewCell {
        guard let labelTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: LabelTableViewCell.reuseIdentifier,
            for: indexPath) as? LabelTableViewCell else {
            fatalError("Could not dequeue \(LabelTableViewCell.reuseIdentifier)")
        }

        labelTableViewCell.configure(text: text, font: font)
        return labelTableViewCell
    }

    private func getSwipableImageViewTableViewCell(
        for indexPath: IndexPath) -> SwipableImageViewTableViewCell {
        guard let swipableImageViewCell = tableView.dequeueReusableCell(
            withIdentifier: SwipableImageViewTableViewCell.reuseIdentifier,
            for: indexPath) as? SwipableImageViewTableViewCell else {
            fatalError("Could not dequeue \(SwipableImageViewTableViewCell.reuseIdentifier)")
        }

        let imageFileNames = Array(exercise.imageNames)
        swipableImageViewCell.configure(imageFileNames: imageFileNames,
                                        isUserMade: exercise.isUserMade)
        return swipableImageViewCell
    }

    @objc private func closeButtonTapped(sender: Any) {
        dismiss(animated: true)
    }

    @objc private func editButtonTapped(sender: Any) {
        let createEditExerciseTableViewController = CreateEditExerciseTableViewController()
        createEditExerciseTableViewController.exercise = exercise
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
        tableData.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        let tableRow = tableData[indexPath.row]

        switch tableRow {
        case .title:
            cell = getTwoLabelsTableViewCell(for: indexPath)
        case .imagesTitle, .instructionsTitle, .tipsTitle:
            cell = getLabelTableViewCell(for: indexPath, text: tableRow.rawValue, font: UIFont.large.medium)
        case .images:
            if exercise.imageNames.isEmpty {
                cell = getLabelTableViewCell(for: indexPath, text: Constants.noImagesText)
            } else {
                cell = getSwipableImageViewTableViewCell(for: indexPath)
            }
        case .instructions, .tips:
            let text = tableRow == .instructions ? exercise.instructions : exercise.tips
            let emptyText = tableRow == .instructions ? Constants.noInstructionsText : Constants.noTipsText
            cell = getLabelTableViewCell(for: indexPath, text: text ?? emptyText)
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
            return exercise.imageNames.isEmpty ?
                UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableItem = tableData[indexPath.row]
        switch tableItem {
        case .images:
            return exercise.imageNames.isEmpty ?
                UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
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
