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
    private var closeButton = CustomButton()
    private var containerView = UIView()
    private var titleLabel = UILabel()
    private var subTitleLabel = UILabel()
    private var tableView = UITableView()
    private var editDisclaimerLabel = UILabel()
    private var editButton = CustomButton()

    private var exerciseInfo = ExerciseInfo()

    private var tableData: [TableRow] = [.imagesTitle, .images, .instructionsTitle,
                                         .instructions, .tipsTitle, .tips]

    weak var dimmedViewDelegate: DimmedViewDelegate?

    convenience init(exerciseInfo: ExerciseInfo) {
        self.init()

        self.exerciseInfo = exerciseInfo
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
        if exerciseInfo.isUserMade {
            containerView.add(subviews: [editButton])
        } else {
            containerView.add(subviews: [editDisclaimerLabel])
        }
    }

    func setupViews() {
        containerView.backgroundColor = .white
        containerView.addCorner(style: .medium)

        closeButton.titleLabel?.font = .normal
        let closeImage = UIImage(named: "close")
        closeButton.setImage(closeImage, for: .normal)
        closeButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        closeButton.add(backgroundColor: .lightGray)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        titleLabel.text = exerciseInfo.name
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle).bold
        titleLabel.numberOfLines = 0
        titleLabel.backgroundColor = .white

        subTitleLabel.text = exerciseInfo.muscles
        subTitleLabel.font = .normal
        subTitleLabel.textColor = .systemGray
        subTitleLabel.minimumScaleFactor = 0.5
        subTitleLabel.adjustsFontSizeToFitWidth = true
        subTitleLabel.backgroundColor = .white

        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(SwipableImageViewTableViewCell.self,
                           forCellReuseIdentifier: SwipableImageViewTableViewCell.reuseIdentifier)
        tableView.register(LargeTitleTableViewCell.self, forCellReuseIdentifier: LargeTitleTableViewCell.reuseIdentifier)
        tableView.register(LabelTableViewCell.self,
                           forCellReuseIdentifier: LabelTableViewCell.reuseIdentifier)

        editDisclaimerLabel.text = Constants.editDisclaimerText
        editDisclaimerLabel.textAlignment = .center
        editDisclaimerLabel.font = UIFont.small.light
        editDisclaimerLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        editDisclaimerLabel.backgroundColor = .clear

        editButton.title = "Edit"
        editButton.titleLabel?.font = .normal
        editButton.add(backgroundColor: .systemBlue)
        editButton.addCorner(style: .small)
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
        closeButton.addCorner(style: .circle(view: closeButton))

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

        let viewToUse = exerciseInfo.isUserMade ? editButton : editDisclaimerLabel
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
        titleLabel.text = exerciseInfo.name
        subTitleLabel.text = exerciseInfo.muscles
    }

    @objc private func closeButtonTapped(sender: Any) {
        dismiss(animated: true)
        dimmedViewDelegate?.removeView()
    }

    @objc private func editButtonTapped(sender: Any) {
        let createEditExerciseTableViewController = CreateEditExerciseTableViewController()
        createEditExerciseTableViewController.exerciseInfo = exerciseInfo
        createEditExerciseTableViewController.exerciseState = .edit
        createEditExerciseTableViewController.createEditExerciseDelegate = self

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
            guard let largeTitleTableViewCell = tableView.dequeueReusableCell(withIdentifier: LargeTitleTableViewCell.reuseIdentifier, for: indexPath) as? LargeTitleTableViewCell else {
                presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
                return UITableViewCell()
            }
            largeTitleTableViewCell.configure(title: tableItem.rawValue)
            cell = largeTitleTableViewCell
        case .images:
            if exerciseInfo.imagesData.isEmpty {
                guard let labelTableViewCell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.reuseIdentifier, for: indexPath) as? LabelTableViewCell else {
                    presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
                    return UITableViewCell()
                }

                labelTableViewCell.configure(text: Constants.noImagesText)
                cell = labelTableViewCell
            } else {
                guard let swipableImageViewCell = tableView.dequeueReusableCell(withIdentifier: SwipableImageViewTableViewCell.reuseIdentifier, for: indexPath) as? SwipableImageViewTableViewCell else {
                    presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
                    return UITableViewCell()
                }

                let imagesDataArray = Array(exerciseInfo.imagesData)
                swipableImageViewCell.configure(imagesData: imagesDataArray)
                cell = swipableImageViewCell
            }
        case .instructions, .tips:
            guard let labelTableViewCell = tableView.dequeueReusableCell(withIdentifier: LabelTableViewCell.reuseIdentifier, for: indexPath) as? LabelTableViewCell else {
                presentCustomAlert(content: "Could not load data.", usesBothButtons: false, rightButtonTitle: "Sounds good")
                return UITableViewCell()
            }

            let text = tableItem == .instructions ? exerciseInfo.instructions : exerciseInfo.tips
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
            return exerciseInfo.imagesData.isEmpty ? UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableItem = tableData[indexPath.row]
        switch tableItem {
        case .images:
            return exerciseInfo.imagesData.isEmpty ? UITableView.automaticDimension : Constants.swipableImageViewTableViewCellHeight
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - CreateEditExerciseDelegate
extension ExercisePreviewViewController: CreateEditExerciseDelegate {
    func updateExerciseInfo(_ currentName: String, info: ExerciseInfo, success: @escaping (() -> Void), fail: @escaping (() -> Void)) {
        ExerciseDataModel.shared.updateExerciseInfo(currentName, info: info, success: { [weak self] in
            DispatchQueue.main.async {
                success()
                self?.exerciseInfo = info
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
