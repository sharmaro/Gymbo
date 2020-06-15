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

    private let startSessionButton: CustomButton = {
        let button = CustomButton()
        button.title = "Start Session"
        button.titleLabel?.textAlignment = .center
        button.add(backgroundColor: .systemBlue)
        button.addCorner(style: .small)
        return button
    }()

    var session: Session?
    var exerciseInfoArray: [ExerciseInfo]?

    private let sessionDataModelManager = SessionDataModel.shared
    private let exercisesDataModelManager = ExerciseDataModel.shared

    weak var sessionProgressDelegate: SessionProgressDelegate?
}

// MARK: - Structs/Enums
private extension SessionPreviewViewController {
    struct Constants {
        static let title = "Preview"

        static let exerciseCellHeight = CGFloat(70)

        static let namePlaceholderText = "Session name"
        static let infoPlaceholderText = "No Info"
    }
}

// MARK: - ViewAdding
extension SessionPreviewViewController: ViewAdding {
    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))

        // This allows there to be a smooth transition from large title to small and vice-versa
        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .all
    }

    func addViews() {
        view.add(subviews: [tableView, startSessionButton])
    }

    func setupViews() {
        view.backgroundColor = .white

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ExerciseTableViewCell.self, forCellReuseIdentifier: ExerciseTableViewCell.reuseIdentifier)

        var dataModel = SessionHeaderViewModel()
        dataModel.name = session?.name ?? Constants.namePlaceholderText
        dataModel.info = session?.info ?? Constants.infoPlaceholderText
        dataModel.textColor = .black

        tableHeaderView.configure(dataModel: dataModel)
        tableHeaderView.isContentEditable = false

        startSessionButton.addTarget(self, action: #selector(startSessionButtonTapped), for: .touchUpInside)
    }

    func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: startSessionButton.topAnchor, constant: -15)
        ])

        tableHeaderView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = tableHeaderView
        NSLayoutConstraint.activate([
            tableHeaderView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            tableHeaderView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 20),
            tableHeaderView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: -20),
            tableHeaderView.topAnchor.constraint(equalTo: tableView.topAnchor)
        ])
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()

        NSLayoutConstraint.activate([
            startSessionButton.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            startSessionButton.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            startSessionButton.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            startSessionButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
}

// MARK: - UIViewController Var/Funcs
extension SessionPreviewViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addViews()
        setupViews()
        addConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard isViewLoaded,
            let session = session else {
                return
        }

        title = Constants.title
        exerciseInfoArray = exercisesDataModelManager.exerciseInfoList(for: session)

        var dataModel = SessionHeaderViewModel()
        dataModel.name = session.name
        dataModel.info = session.info
        dataModel.textColor = .black
        tableHeaderView.configure(dataModel: dataModel)

        tableView.reloadWithoutAnimation()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Used for resizing the tableView.headerView when the info text view becomes large enough
        tableView.tableHeaderView = tableView.tableHeaderView
        tableView.tableHeaderView?.layoutIfNeeded()
    }
}

// MARK: - Funcs
extension SessionPreviewViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func editButtonTapped() {
        guard let session = session else {
            presentCustomAlert(content: "Can't edit current Session.", usesBothButtons: false, rightButtonTitle: "Sounds good") {
            }
            return
        }

        let createEditSessionViewController = CreateEditSessionViewController()
        createEditSessionViewController.sessionState = .edit
        createEditSessionViewController.session = session
        navigationController?.pushViewController(createEditSessionViewController, animated: true)
    }

    @objc private func startSessionButtonTapped(_ sender: Any) {
        dismiss(animated: true)
        sessionProgressDelegate?.sessionDidStart(session)
    }
}

// MARK: - UITableViewDataSource
extension SessionPreviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseInfoArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let exerciseTableViewCell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as? ExerciseTableViewCell,
            let exercise = exerciseInfoArray?[indexPath.row] else {
            fatalError("Could not dequeue \(ExerciseTableViewCell.reuseIdentifier)")
        }

        exerciseTableViewCell.configure(dataModel: exercise)
        return exerciseTableViewCell
    }
}

// MARK: - UITableViewDelegate
extension SessionPreviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.exerciseCellHeight
    }
}
