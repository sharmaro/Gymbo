//
//  SessionPreviewViewController.swift
//  Gymbo
//
//  Created by Rohan Sharma on 10/23/19.
//  Copyright © 2019 Rohan Sharma. All rights reserved.
//

import UIKit

// MARK: - Properties
class SessionPreviewViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let tableHeaderView = SessionHeaderView()
    private var didLayoutTableHeaderView = false

    private let startSessionButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start Session"
        button.titleLabel?.textAlignment = .center
        button.add(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    private let sessionDataModel = SessionDataModel()

    var session: Session?

    weak var sessionProgressDelegate: SessionProgressDelegate?
}

// MARK: - Structs/Enums
private extension SessionPreviewViewController {
    struct Constants {
        static let title = "Preview"

        static let startButtonHeight = CGFloat(45)
        static let startButtonBottomSpacing = CGFloat(-20)
        static let exerciseCellHeight = CGFloat(70)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionPreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        setupColors()
        addConstraints()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        if !didLayoutTableHeaderView {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.tableHeaderView?.layoutIfNeeded()
                self.tableView.tableHeaderView = self.tableView.tableHeaderView
            }
        }
        didLayoutTableHeaderView = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupColors()
    }
}

// MARK: - ViewAdding
extension SessionPreviewViewController: ViewAdding {
    func setupNavigationBar() {
        title = Constants.title

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView, startSessionButton])
    }

    func setupViews() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseTableViewCell.self,
                           forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)

        let spacing = CGFloat(15)
        tableView.contentInset.bottom = Constants.startButtonHeight +
                                        (-1 * Constants.startButtonBottomSpacing) +
                                        spacing

        setupTableHeaderView()

        startSessionButton.addTarget(self, action: #selector(startSessionButtonTapped), for: .touchUpInside)
    }

    func setupColors() {
        [view, tableView].forEach { $0.backgroundColor = .dynamicWhite }
    }

    func addConstraints() {
        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = tableHeaderView

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.widthAnchor.constraint(equalTo: tableView.widthAnchor),

            startSessionButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 20),
            startSessionButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -20),
            startSessionButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: Constants.startButtonBottomSpacing),
            startSessionButton.heightAnchor.constraint(equalToConstant: Constants.startButtonHeight)
        ])
    }
}

// MARK: - Funcs
extension SessionPreviewViewController {
    private func setupTableHeaderView() {
        var dataModel = SessionHeaderViewModel()
        dataModel.firstText = session?.name ?? Constants.namePlaceholderText
        dataModel.secondText = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .dynamicBlack

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = false
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func editButtonTapped() {
        guard let session = session else {
            presentCustomAlert(content: "Can't edit current Session.",
                               usesBothButtons: false,
                               rightButtonTitle: "Sounds good")
            return
        }

        let createEditSessionTableViewController = CreateEditSessionTableViewController()
        createEditSessionTableViewController.sessionState = .edit
        createEditSessionTableViewController.session = session
        createEditSessionTableViewController.sessionDataModelDelegate = self
        navigationController?.pushViewController(createEditSessionTableViewController, animated: true)
    }

    @objc private func startSessionButtonTapped(_ sender: Any) {
        Haptic.sendImpactFeedback(.heavy)
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.sessionProgressDelegate?.sessionDidStart(self.session)
        }
    }
}

// MARK: - UITableViewDataSource
extension SessionPreviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        session?.exercises.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let exerciseTableViewCell = tableView.dequeueReusableCell(
            withIdentifier: ExerciseTableViewCell.reuseIdentifier,
            for: indexPath) as? ExerciseTableViewCell,
            let exercise = session?.exercises[indexPath.row] else {
            fatalError("Could not dequeue \(ExerciseTableViewCell.reuseIdentifier)")
        }

        exerciseTableViewCell.configure(dataModel: exercise)
        return exerciseTableViewCell
    }
}

// MARK: - UITableViewDelegate
extension SessionPreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.exerciseCellHeight
    }
}

// MARK: -
extension SessionPreviewViewController: SessionDataModelDelegate {
    func update(_ currentName: String,
                session: Session,
                success: @escaping (() -> Void),
                fail: @escaping (() -> Void)) {
        sessionDataModel.update(currentName, session: session, success: { [weak self] in
            success()
            self?.session = session
            DispatchQueue.main.async {
                self?.setupTableHeaderView()
                // Updating collectionView in SessionsCollectionViewController
                NotificationCenter.default.post(name: .reloadDataWithoutAnimation, object: nil)
            }
        }, fail: fail)
    }
}
